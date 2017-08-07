class LineItem < ApplicationRecord
  belongs_to :itemable, polymorphic:true 
  belongs_to :stock, foreign_key: 'stock_id'
  belongs_to :cart
  belongs_to :order
  belongs_to :employee, foreign_key: 'user_id'
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
      from_date = hash[:from_date].kind_of?(Time) ? hash[:from_date] : Time.parse(hash[:from_date].strftime('%Y-%m-%d 12:00:00'))
      to_date = hash[:to_date].kind_of?(Time) ? hash[:to_date] : Time.parse(hash[:to_date].strftime('%Y-%m-%d 12:59:59'))
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
    if self.cash?
      Accounting::Entry.create!(commercial_document_id: self.order.member.id, 
        commercial_document_type: self.order.member.class, date: self.order.date, 
        description: "Sales Return for #{self.stock.try(:name)}: Quantity: #{self.quantity}", 
        debit_amounts_attributes: [{amount: self.total_price, account: "Sales Returns and Allowances"}, {amount: self.sold_stock_price, account: "Merchandise Inventory"}], 
        credit_amounts_attributes:[{amount: self.total_price, account: 'Cash on Hand'}, {amount: self.sold_stock_price, account: 'Cost of Goods Sold'}], 
        employee_id: self.user_id)

    elsif self.credit?
      Accounting::Entry.create!(commercial_document_id: self.order.member.id, 
        commercial_document_type: self.order.member.class, date: self.order.date, 
        description: "Sales Return for #{self.stock.try(:name)}: Quantity: #{self.quantity}", 
        debit_amounts_attributes: [{amount: self.total_price, account: "Sales Returns and Allowances"}, {amount: self.sold_stock_price, account: "Merchandise Inventory"}], 
        credit_amounts_attributes:[{amount: self.total_price, account: 'Accounts Receivables Trade - Current'}, {amount: self.sold_stock_price, account: 'Cost of Goods Sold'}], 
        employee_id: self.user_id)
    end
  end

  def compute_total_price
    self.total_price = self.unit_price * quantity
  end

  def create_entry_for_interest_program
    @accounts_receivable = Accounting::Account.find_by(name: "Accounts Receivables Trade - Current")
    @interest_income_from_credit_sales = Accounting::Account.find_by(name: "Interest Income from Credit Sales")

    (LineItem.where(pricing_type: "wholesale").credit +  LineItem.where(pricing_type: "retail").credit).each do |line_item|
      if line_item.stock.product.program_product? == true
        Accounting::Entry.create(order_id: line_item.order.id, commercial_document_id: line_item.order.member.id, 
        commercial_document_type: line_item.order.member.class, date: Time.zone.now, 
        description: "Interest for credit order ##{self.reference_number}", 
        debit_amounts_attributes: [{amount: self.stock_cost, account: @accounts_receivable}], 
        credit_amounts_attributes:[{amount: self.stock_cost, account: @interest_income_from_credit_sales}],  
        employee_id: line_item.order.employee_id)
        
        interest = (line_item.stock.product.program.amount / 100) * line_item.total_price
        line_item.interest_programs.create!(line_item_id: line_item.id, amount: interest)
      end
    end
  end

  private
  def ensure_quantity_is_available
    return false
  end
end
