class LineItem < ApplicationRecord
  belongs_to :itemable, polymorphic:true 
  belongs_to :stock, foreign_key: 'stock_id'
  belongs_to :cart
  belongs_to :order
  belongs_to :employee, foreign_key: 'user_id'
  belongs_to :customer, foreign_key: 'customer_id'
  has_many :interest_programs
  enum pricing_type: [:retail, :wholesale, :catering]
  scope :by_total_price, -> { all.to_a.sort_by(&:total_price) }
  
  validates :quantity, numericality: { less_than_or_equal_to: :stock_quantity }, on: :create
  delegate :name, to: :stock, prefix: true
  delegate :cash?, :credit?, to: :order

  def order_date
    order.date
  end
  
  def self.created_between(hash={})
    if hash[:from_date] && hash[:to_date]
      from_date = hash[:from_date].kind_of?(Time) ? hash[:from_date] : DateTime.parse(hash[:from_date].strftime('%Y-%m-%d 12:00:00 AM'))
      to_date = hash[:to_date].kind_of?(Time) ? hash[:to_date] : DateTime.parse(hash[:to_date].strftime('%Y-%m-%d 23:59:59 PM'))
      where('created_at' => from_date..to_date)
    else
      all
    end
  end
  def stock_quantity
    if stock
      self.stock.in_stock
    end
  end
  def self.cash
    all.select{|a| a.cash? }
  end
  def cash?
    order.present? && order.cash?
  end
  def self.credit
    all.select{|a| a.credit? }
  end
  def credit?
    order.present? && order.credit?
  end

  def cost_of_goods_sold
    stock.unit_cost * quantity
  end

  def income
    total_price - cost_of_goods_sold
  end

  def self.income
    all.to_a.sum { |item| item.income }
  end

  def self.cost_of_goods_sold
    all.to_a.sum { |item| item.cost_of_goods_sold }
  end

  def total_retail_price
    unit_price * quantity
  end

  def self.total_wholesale_price
    self.all.to_a.sum { |item| item.unit_price }
  end

  def total_wholesale_price
    unit_price * quantity
  end

  def self.total_wholesale_price
    self.all.to_a.sum { |item| item.unit_price }
  end

  def self.total_retail_price
    self.all.to_a.sum { |item| item.total_price }
  end

  def type
    if cash?
      "Cash"
    elsif credit?
      "Credit"
    end
  end

  def return_quantity_to_stock!
    self.stock.update_attributes!(quantity: self.quantity + self.stock.quantity)
  end

  def sold_stock_price
    self.quantity * self.stock.unit_cost
  end
        
  def create_entry_for_sales_return
    @sales = Accounting::Account.find_by(name: "Sales")
    @cash_on_hand = Accounting::Account.find_by(name: "Cash on Hand")
    @merchandise_inventory = Accounting::Account.find_by(name: "Merchandise Inventory")
    @cost_of_goods_sold = Accounting::Account.find_by(name: "Cost of Goods Sold")
    if cash?
      Accounting::Entry.create!(commercial_document_id: self.order.id, 
        commercial_document_type: self.order.class, date: self.order.date, 
        description: "Sales Return for #{self.stock.try(:name)}: Quantity: #{self.quantity}", 
        debit_amounts_attributes: [{amount: self.total_price, account: @sales}, {amount: self.sold_stock_price, account: @merchandise_inventory}], 
        credit_amounts_attributes:[{amount: self.total_price, account: @cash_on_hand}, {amount: self.sold_stock_price, account: @cost_of_goods_sold}], 
        employee_id: self.user_id)

    elsif credit?
      Accounting::Entry.create!(commercial_document_id: self.order.id, 
        commercial_document_type: self.order.class, date: self.order.date, 
        description: "Sales Return for #{self.stock.try(:name)}: Quantity: #{self.quantity}", 
        debit_amounts_attributes: [{amount: self.total_price, account: @sales}, {amount: self.sold_stock_price, account: @merchandise_inventory}], 
        credit_amounts_attributes:[{amount: self.total_price, account: @cash_on_hand}, {amount: self.sold_stock_price, account: @cost_of_goods_sold}], 
        employee_id: self.user_id)
    end
  end

  def compute_total_price
    self.total_price = self.unit_price * quantity
  end

  private
  def ensure_quantity_is_available
    return false
  end
end
