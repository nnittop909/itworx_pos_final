class Stock < ApplicationRecord
  include PgSearch
  pg_search_scope :search_by_name, :against => [:name, :serial_number], :associated_against => {
    :product => [:name_and_description]}
  enum stock_type:[:purchased, :returned, :discontinued, :forwarded]
  enum payment_type: [:cash, :credit]
  belongs_to :product
  belongs_to :employee
  belongs_to :supplier, optional: true
  has_one :entry, class_name: "Accounting::Entry", foreign_key: 'stock_id', dependent: :destroy
  has_many :line_items
  has_many :orders, through: :line_items
  has_many :refunds
  has_many :stock_transfers
  before_update :set_prices
  scope :created_between, lambda {|start_date, end_date| where("date >= ? AND date <= ?", start_date, end_date )}

  validates :quantity, :supplier_id, :unit_cost, :total_cost,  presence: true, numericality: true
  before_save :set_date, :set_name

  def to_s
    name
  end

  def self.returned
    all.order(date: :desc).where(stock_type: 1)
  end

  def self.discontinued
    all.order(date: :desc).where(stock_type: 2)
  end

  def self.forwarded
    all.order(date: :desc).where(stock_type: 3)
  end

  def self.total_cost_of_purchase
    all.order(date: :desc).where.not("received").sum(:total_cost)
  end

  def self.entered_on(hash={})
    if hash[:from_date] && hash[:to_date]
      from_date = hash[:from_date].kind_of?(Time) ? hash[:from_date] : DateTime.parse(hash[:from_date])
      to_date = hash[:to_date].kind_of?(Time) ? hash[:to_date] : DateTime.parse(hash[:to_date])
      where('date' => from_date..to_date)
    else
      all
    end
  end

  def in_stock
    if self.returned? || self.discontinued? || self.forwarded?
      0
    else
      quantity - sold
    end
  end

  def sold
    line_items.sum(:quantity)
  end

  def total_cost_less_discount
    total_cost - discount_amount
  end

  def total_cost_less_discount_less_freight_in
    (quantity * unit_cost) - discount_amount
  end

  def total_cost_less_freight_in
    total_cost - freight_amount
  end

  def total_cost_plus_freight_in
    total_cost
  end

  def total_cost_less_discount_plus_freight_in
    total_cost - discount_amount
  end

  def self.expired
    all.order(date: :desc).select{ |a| a.expired?}
  end

  def self.available
    all.order(date: :desc).where.not(stock_type: [1,2,3]).select{ |a| !a.out_of_stock? && !a.expired?}
  end

  def self.out_of_stock
    all.order(date: :desc).where.not(stock_type: [1,2,3]).select{ |a| a.out_of_stock?}
  end

  def expired?
    if expiry_date.present?
      Time.zone.now >= expiry_date && !discontinued?
    else
      false
    end
  end

  def expired_and_low_stock?
    expired? && low_stock?
  end

  def discontinued?
    self.stock_type == "discontinued"
  end

  def expired_and_discontinued?
    expired? && discontinued?
  end

  def returned?
    self.stock_type == "returned"
  end

  def forwarded?
    self.stock_type == "forwarded"
  end

  def out_of_stock?
    in_stock.zero? || in_stock.negative?
  end

  def low_stock?
    quantity <= product.stock_alert_count && !out_of_stock?
  end

  def status
    if out_of_stock?
      "Out of Stock"
    elsif low_stock? && !expired? && !discontinued?
      "Low on Stock"
    elsif expired_and_low_stock? || (expired? && !discontinued?)
      "Expired"
    elsif expired_and_discontinued? || self.discontinued?
      "Discontinued"
    elsif returned?
      "Returned"
    elsif forwarded?
      "Forwarded"
    end
  end

  def set_stock_status_to_product
    if !out_of_stock? && !low_stock?
      self.product.available!
    elsif low_stock?
      self.product.low_stock!
    elsif out_of_stock?
      self.product.out_of_stock!
    end
  end

  def in_stock_amount
    in_stock * unit_cost
  end

  def create_expense_from_expired_stock
    @spoilage_breakage_and_loses = Accounting::Account.find_by(name: "Spoilage, Breakage and Losses (Selling/Marketing Cost)")
    @merchandise_inventory = Accounting::Account.find_by(name: "Merchandise Inventory")

    Accounting::Entry.create!(stock_id: self.id, commercial_document_id: self.id, 
      commercial_document_type: self.class, date: Time.zone.now, description: "Expired stock for #{self.product.name_and_description} with quantity of #{self.quantity} #{self.product.unit}", 
      debit_amounts_attributes: [amount: self.in_stock_amount, account: @spoilage_breakage_and_loses], 
      credit_amounts_attributes:[amount: self.in_stock_amount, account: @merchandise_inventory], 
      employee_id: self.employee_id)
  end

  def remove_expense_from_expired_stock
    @entry = Accounting::Entry.where(stock_id: self.id).where(commercial_document_id: self.id).where(commercial_document_type: self.class).where(description: "Expired stock for #{self.product.name_and_description} with quantity of #{self.quantity} #{self.product.unit}").last
    if @entry.present?
      @entry.destroy
    else
      false
    end
  end

  def create_entry
    @cash_on_hand = Accounting::Account.find_by(name: "Cash on Hand")
    @cost_of_goods_sold = Accounting::Account.find_by(name: "Cost of Goods Sold")
    @sales = Accounting::Account.find_by(name: "Sales")
    @merchandise_inventory = Accounting::Account.find_by(name: "Merchandise Inventory")
    @freight_in = Accounting::Account.find_by(name: "Freight In")
    @accounts_payable = Accounting::Account.find_by(name: "Accounts Payable-Trade")
    @accounts_receivable = Accounting::Account.find_by(name: "Accounts Receivables Trade - Current")
    #CASH PURCHASE ENTRY##
    if self.cash? && !discounted? && !has_freight?
      Accounting::Entry.create!(stock_id: self.id, commercial_document_id: self.supplier.id, 
        commercial_document_type: self.supplier.class, date: self.date, 
        description: "Cash Purchase of stocks", 
        debit_amounts_attributes: [amount: self.total_cost, account: @merchandise_inventory], 
        credit_amounts_attributes:[amount: self.total_cost, account: @cash_on_hand],  
        employee_id: self.employee_id)

    elsif self.cash? && discounted? && !has_freight?
      Accounting::Entry.create!(stock_id: self.id, commercial_document_id: self.supplier.id, 
        commercial_document_type: self.supplier.class, date: self.date, 
        description: "Cash Purchase of stocks with discount of #{self.discount_amount}", 
        debit_amounts_attributes: [amount: self.total_cost, account: @merchandise_inventory], 
        credit_amounts_attributes:[amount: self.total_cost, account: @cash_on_hand],  
        employee_id: self.employee_id)

    elsif self.cash? && !discounted? && has_freight?
      Accounting::Entry.create!(stock_id: self.id, commercial_document_id: self.supplier.id, 
        commercial_document_type: self.supplier.class, date: self.date, 
        description: "Cash Purchase of stocks with freight in of #{self.freight_amount}", 
        debit_amounts_attributes: [{amount: self.total_cost_less_freight_in, account: @merchandise_inventory}, {amount: self.freight_amount, account: @freight_in}], 
        credit_amounts_attributes:[{amount: self.total_cost_less_freight_in, account: @cash_on_hand}, {amount: self.freight_amount, account: @cash_on_hand}], 
        employee_id: self.employee_id)

    elsif self.cash? && discounted? && has_freight?
      Accounting::Entry.create!(stock_id: self.id, commercial_document_id: self.supplier.id, 
        commercial_document_type: self.supplier.class, date: self.date, 
        description: "Cash Purchase of stocks with discount of #{self.discount_amount} and freight in of #{self.freight_amount}", 
        debit_amounts_attributes: [{amount: self.total_cost_less_discount_less_freight_in, account: @merchandise_inventory}, {amount: self.freight_amount, account: @freight_in}], 
        credit_amounts_attributes:[{amount: self.total_cost_less_discount_less_freight_in, account: @cash_on_hand}, {amount: self.freight_amount, account: @cash_on_hand}],  
        employee_id: self.employee_id)
      
    #Cedit PURCHASE ENTRY##
    elsif self.credit? && !discounted? && !has_freight?
      Accounting::Entry.create!(stock_id: self.id, commercial_document_id: self.supplier.id, 
        commercial_document_type: self.supplier.class, date: self.date, 
        description: "Credit Purchase of stocks", 
        debit_amounts_attributes: [amount: self.total_cost, account: @merchandise_inventory], 
        credit_amounts_attributes:[amount: self.total_cost, account: @accounts_payable],  
        employee_id: self.employee_id)

    elsif self.credit? && discounted? && !has_freight?
      Accounting::Entry.create!(stock_id: self.id, commercial_document_id: self.supplier.id, 
        commercial_document_type: self.supplier.class, date: self.date, 
        description: "Credit Purchase of stocks with discount of #{self.discount_amount}", 
        debit_amounts_attributes: [amount: self.total_cost, account: @merchandise_inventory], 
        credit_amounts_attributes:[amount: self.total_cost, account: @accounts_payable],  
        employee_id: self.employee_id)

    elsif self.credit? && !discounted? && has_freight?
      Accounting::Entry.create!(stock_id: self.id, commercial_document_id: self.supplier.id, 
        commercial_document_type: self.supplier.class, date: self.date, 
        description: "Credit Purchase of stocks with freight in of #{self.freight_amount}", 
        debit_amounts_attributes: [{amount: self.total_cost_less_freight_in, account: @merchandise_inventory}, {amount: self.freight_amount, account: @freight_in}], 
        credit_amounts_attributes:[{amount: self.total_cost_less_freight_in, account: @accounts_payable}, {amount: self.freight_amount, account: @accounts_payable}],  
        employee_id: self.employee_id)

    elsif self.credit? && discounted? && has_freight?
      Accounting::Entry.create!(stock_id: self.id, commercial_document_id: self.supplier.id, 
        commercial_document_type: self.supplier.class, date: self.date, 
        description: "Credit Purchase of stocks with discount of #{self.discount_amount} and freight in of #{self.freight_amount}", 
        debit_amounts_attributes: [{amount: self.total_cost_less_discount_less_freight_in, account: @merchandise_inventory}, {amount: self.freight_amount, account: @freight_in}], 
        credit_amounts_attributes:[{amount: self.total_cost_less_discount_less_freight_in, account: @accounts_payable}, {amount: self.freight_amount, account: @accounts_payable}], 
        employee_id: self.employee_id)
    end
  end

  private
  def set_prices
    self.retail_price = self.product.retail_price
    self.wholesale_price = self.product.wholesale_price
  end
  def set_date
    if self.date.nil?
      self.date = Time.zone.now
    end
  end
  def set_name
    self.name = self.product.name_and_description
  end
end
