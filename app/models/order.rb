class Order < ApplicationRecord
  include PgSearch
  pg_search_scope :text_search, :against => [:reference_number],
                  :associated_against => {:member => [:full_name], :invoice_number => [:number]}

  has_one :official_receipt_number, dependent: :destroy
  has_one :invoice_number, dependent: :destroy
  has_one :entry, class_name: "Accounting::Entry", foreign_key: 'order_id', dependent: :destroy

  belongs_to :employee, foreign_key: 'employee_id'
  belongs_to :member, foreign_key: 'user_id'
  belongs_to :department, foreign_key: 'user_id'
  enum pay_type:[:cash, :credit]
  enum order_type: [:retail, :wholesale, :catering]
  enum delivery_type: [:pick_up, :deliver, :to_go]
  has_many :line_items, dependent: :destroy
  has_many :catering_line_items, dependent: :destroy
  has_many :stocks, through: :line_items
  has_one :discount, dependent: :destroy
  belongs_to :tax
  before_save :set_date, :set_user
  accepts_nested_attributes_for :discount
  scope :created_between, lambda {|start_date, end_date| where("date >= ? AND date <= ?", start_date, end_date )}

  def self.created_between(hash={})
    if hash[:from_date] && hash[:to_date]
      from_date = hash[:from_date].kind_of?(Time) ? hash[:from_date] : Time.parse(hash[:from_date].strftime('%Y-%m-%d 12:00:00'))
      to_date = hash[:to_date].kind_of?(Time) ? hash[:to_date] : Time.parse(hash[:to_date].strftime('%Y-%m-%d 12:59:59'))
      where('date' => from_date..to_date)
    else
      all
    end
  end

  def self.cost_of_goods_sold
    all.to_a.sum{ |a| a.cost_of_goods_sold }
  end

  def cost_of_goods_sold
    line_items.cost_of_goods_sold
  end

  def self.income
    all.to_a.sum{ |a| a.income }
  end

  def income
    line_items.income - total_discount
  end
  
  def name
    customer_name
  end
  def customer_name
    member.try(:full_name)
  end
  def vatable_amount
    0
  end
  def vat_percentage
    12
  end
  def machine_accreditation
    ""
  end
  def total_discount
    if discount.present?
      discount.amount
    else
      0
    end
  end
  def reference_number
    "#{id.to_s.rjust(8, '0')}"
  end
  def self.total_amount_without_discount
    all.map{|a| a.total_amount_without_discount }.sum
  end
  def self.total_amount_less_discount
    all.map{|a| a.total_amount_less_discount }.sum
  end
  def self.total_discount
    all.map{|a| a.total_discount }.sum
  end
  def tax_rate
    if business.non_vat_registered?
      0.03
    elsif business.vat_registered?
      0.12
    end
  end

  def total_catering_cost
    catering_line_items.sum(:total_cost)
  end

  def total_catering_less_discount
    total_catering_cost - total_discount
  end

  def total_amount_plus_catering
    line_items.sum(:total_price) + total_catering_cost
  end
  
  def total_amount_without_discount
    if self.catering?
      line_items.sum(:total_price) + total_catering_cost
    else
      line_items.sum(:total_price)
    end
  end

  def total_amount_with_discount
    total_amount_without_discount + total_discount
  end

  def total_amount_less_discount
    total_amount_without_discount - total_discount
  end

  def add_line_items_from_cart(cart)
    cart.line_items.each do |item|
      item.cart_id = nil
      line_items << item
    end
  end

  def add_line_items_from_catering_cart(catering_cart)
    catering_cart.catering_line_items.each do |item|
      item.catering_cart_id = nil
      catering_line_items << item
    end
  end

  def stock_cost
    line_items.map{|a| a.stock.unit_cost * a.quantity}.sum
  end

  def return_line_items_to_stock!
    self.line_items do |line_item|
      line_item.stock.update_attributes!(quantity: line_item.quantity + line_item.stock.quantity)
    end
  end

  def subscribe_to_program
    if self.credit?
      self.line_items do |line_item|
        ProgramSubscription.create(member_id: self.member.id, program_id: self.line_item.stock.product.program.id)
      end
    end
  end

  def create_entry
    @cash_on_hand = Accounting::Account.find_by(name: "Cash on Hand")
    @purchases = Accounting::Account.find_by(name: "Purchases")
    @cost_of_goods_sold = Accounting::Account.find_by(name: "Cost of Goods Sold")
    @sales = Accounting::Account.find_by(name: "Sales")
    @merchandise_inventory = Accounting::Account.find_by(name: "Merchandise Inventory")
    @accounts_receivable = Accounting::Account.find_by(name: "Accounts Receivables Trade - Current")

    if self.cash? && !self.discounted? && !self.catering?
      Accounting::Entry.create(order_id: self.id, commercial_document_id: self.member.id, 
        commercial_document_type: self.member.class, date: self.date, 
        description: "Payment for order ##{self.reference_number}", 
        debit_amounts_attributes: [{amount: self.stock_cost, account: @cost_of_goods_sold}], 
        credit_amounts_attributes:[{amount: self.stock_cost, account: @merchandise_inventory}],  
        employee_id: self.employee_id)

    elsif self.credit? && !self.discounted? && !self.catering?
      Accounting::Entry.create(order_id: self.id, commercial_document_id: self.member.id, 
        commercial_document_type: self.member.class, date: self.date, 
        description: "Credit for order ##{self.reference_number}", 
        debit_amounts_attributes: [{amount: self.total_amount_without_discount, account: @accounts_receivable}, {amount: self.stock_cost, account: @cost_of_goods_sold}], 
        credit_amounts_attributes:[{amount: self.total_amount_without_discount, account: @sales}, {amount: self.stock_cost, account: @merchandise_inventory}], 
        employee_id: self.employee_id)

    elsif self.cash? && self.discounted? && !self.catering?
      Accounting::Entry.create(order_id: self.id, commercial_document_id: self.member.id, 
        commercial_document_type: self.member.class, date: self.date, 
        description: "Payment for order ##{self.reference_number} with discount of #{self.total_discount}", 
        debit_amounts_attributes: [{amount: self.stock_cost, account: @cost_of_goods_sold}], 
        credit_amounts_attributes:[{amount: self.stock_cost, account: @merchandise_inventory}],  
        employee_id: self.employee_id)

    elsif self.catering? && !self.discounted?
      Accounting::Entry.create(order_id: self.id, commercial_document_id: self.user_id, 
        commercial_document_type: self.department.class, date: self.date, 
        description: "Credit for catering order ##{self.reference_number}", 
        debit_amounts_attributes: [{amount: self.total_amount_without_discount, account: @accounts_receivable}, {amount: self.stock_cost, account: @cost_of_goods_sold}], 
        credit_amounts_attributes:[{amount: self.total_amount_without_discount, account: @sales}, {amount: self.stock_cost, account: @merchandise_inventory}], 
        employee_id: self.employee_id)
      Accounting::Entry.create(order_id: self.id, commercial_document_id: self.user_id, 
        commercial_document_type: self.department.class, date: self.date, 
        description: "Purchase of items for catering order ##{self.reference_number}", 
        debit_amounts_attributes: [{amount: self.total_catering_cost, account: @purchases}], 
        credit_amounts_attributes:[{amount: self.total_catering_cost, account: @cash_on_hand}], 
        employee_id: self.employee_id)

    elsif self.catering? && self.discounted?
      Accounting::Entry.create(order_id: self.id, commercial_document_id: self.user_id, 
        commercial_document_type: self.department.class, date: self.date, 
        description: "Credit for catering order ##{self.reference_number}", 
        debit_amounts_attributes: [{amount: self.total_amount_less_discount, account: @accounts_receivable}, {amount: self.stock_cost, account: @cost_of_goods_sold}], 
        credit_amounts_attributes:[{amount: self.total_amount_less_discount, account: @sales}, {amount: self.stock_cost, account: @merchandise_inventory}], 
        employee_id: self.employee_id)
      Accounting::Entry.create(order_id: self.id, commercial_document_id: self.user_id, 
        commercial_document_type: self.department.class, date: self.date, 
        description: "Purchase of items for catering order ##{self.reference_number}", 
        debit_amounts_attributes: [{amount: self.total_catering_cost, account: @purchases}], 
        credit_amounts_attributes:[{amount: self.total_catering_cost, account: @cash_on_hand}], 
        employee_id: self.employee_id)

    elsif self.credit? && self.discounted? && !self.catering?
      entry_for_discounted_credit
    end
  end

  def entry_for_discounted_credit
    Accounting::Entry.create(order_id: self.id, commercial_document_id: self.member.id, 
      commercial_document_type: self.member.class, date: self.date, 
      description: "Credit for order ##{self.reference_number} with discount of #{self.total_discount}", 
      debit_amounts_attributes: [{amount: self.total_amount_less_discount, account: @accounts_receivable}, {amount: self.stock_cost, account: @cost_of_goods_sold}], 
      credit_amounts_attributes:[{amount: self.total_amount_less_discount, account: @sales}, {amount: self.stock_cost, account: @merchandise_inventory}],  
      employee_id: self.employee_id)
  end

  private

  def ensure_not_referenced_by_line_items
    errors[:base] << "Order still referenced by line items" if self.line_items.present?
    return false 
  end

  def set_date
    self.date ||= Time.zone.now
  end

  def set_user
    if user_id.nil?
      user_id = User.find_by(first_name: 'Guest').id
    end
  end
end
