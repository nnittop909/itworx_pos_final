class Order < ApplicationRecord
  include PgSearch
  pg_search_scope :text_search, :against => [:reference_number],
                  :associated_against => {:member => [:full_name], :invoice_number => [:number]}

  has_one :official_receipt, as: :receiptable
  has_one :invoice_number, dependent: :destroy
  has_one :entry, class_name: "Accounting::Entry", as: :commercial_document, dependent: :destroy

  belongs_to :employee, foreign_key: 'employee_id'
  belongs_to :customer, foreign_key: 'customer_id'
  enum pay_type:[:cash, :credit]
  enum order_type: [:retail, :wholesale, :catering]
  enum payment_status: [:paid, :unpaid]
  enum delivery_type: [:pick_up, :deliver, :to_go]
  has_many :line_items, dependent: :destroy
  has_many :stocks, through: :line_items
  has_one :discount, dependent: :destroy

  scope :sold_on, lambda {|start_date, end_date| where("date >= ? AND date <= ?", start_date, end_date )}
  belongs_to :tax
  before_save :set_date, :set_customer
  accepts_nested_attributes_for :discount
  accepts_nested_attributes_for :entry

  def self.created_between(hash={})
    if hash[:from_date] && hash[:to_date]
      from_date = hash[:from_date].kind_of?(Time) ? hash[:from_date] : DateTime.parse(hash[:from_date].strftime('%Y-%m-%d 12:00:00 AM'))
      to_date = hash[:to_date].kind_of?(Time) ? hash[:to_date] : DateTime.parse(hash[:to_date].strftime('%Y-%m-%d 23:59:59 PM'))
      where('date' => from_date..to_date)
    else
      all
    end
  end

  def create_interest_on_feeds_program
    accounts_receivables_trade = Accounting::Account.find_by(name: "Accounts Receivables Trade - Current")
    interest_income_from_credit_sales = Accounting::Account.find_by(name: "Interest Income from Credit Sales")
    line_items.each do |l|
      if l.stock.product.program.id == feeds_program.id
        program = l.stock.product.program
        interest = (program.interest_rate / 100) * l.total_price
        InterestProgram.create(line_item_id: l.id, amount: interest)
        Accounting::Entry.create(order_id: self.id, commercial_document_id: self.customer_id, 
        commercial_document_type: self.customer.class, date: self.date, 
        description: "Interest for order ##{self.reference_number}.", 
        debit_amounts_attributes: [{amount: interest, account: accounts_receivables_trade}], 
        credit_amounts_attributes:[{amount: interest, account: interest_income_from_credit_sales}], 
        employee_id: self.employee_id)
      end
    end
  end

  def feeds_program
    Program.find_by(name: "Feeds")
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
    customer.try(:full_name)
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
  
  def total_amount_without_discount
    line_items.sum(:total_price)
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

  def stock_cost
    line_items.map{|a| a.stock.unit_cost * a.quantity}.sum
  end

  def return_line_items_to_stock!
    line_items do |line_item|
      line_item.stock.update_attributes!(quantity: line_item.quantity + line_item.stock.quantity)
    end
  end

  def remove_entry_for_return_order!
    Accounting::Entry.find_by(order_id: id).destroy
  end

  def subscribe_to_program!
    if self.line_items.last.stock.product.program.present?
      ProgramSubscription.create(customer_id: self.customer_id, program_id: self.line_items.last.stock.product.program.id)
    end
  end

  def unsubscribe_to_program!
    self.line_items.all.each do |l|

    end
  end

  def set_customer_has_credit_to_true!
    Customer.find(self.customer.id).update(has_credit: true)
  end

  def set_has_credit_to_false!
    Customer.find(self.customer.id).update(has_credit: false)
  end

  def create_entry
    @cash_on_hand = Accounting::Account.find_by(name: "Cash on Hand - Teller")
    @purchases = Accounting::Account.find_by(name: "Purchases")
    @cost_of_goods_sold = Accounting::Account.find_by(name: "Cost of Goods Sold")
    @sales = Accounting::Account.find_by(name: "Sales")
    @merchandise_inventory = Accounting::Account.find_by(name: "Merchandise Inventory")
    @accounts_receivable = Accounting::Account.find_by(name: "Accounts Receivables Trade - Current")

    if self.cash? && !self.discounted?
      Accounting::Entry.create(entry_type: "cash_order", order_id: self.id, commercial_document_id: self.customer_id, 
        commercial_document_type: self.customer.class, date: self.date, 
        description: "Payment for order ##{self.reference_number}", 
        debit_amounts_attributes: [{amount: self.total_amount_without_discount, account: @cash_on_hand}, {amount: self.stock_cost, account: @cost_of_goods_sold}], 
        credit_amounts_attributes:[{amount: self.total_amount_without_discount, account: @sales}, {amount: self.stock_cost, account: @merchandise_inventory}],  
        employee_id: self.employee_id)

    elsif self.credit? && !self.discounted?
      Accounting::Entry.create(entry_type: "credit_order", order_id: self.id, commercial_document_id: self.customer_id, 
        commercial_document_type: self.customer.class, date: self.date, 
        description: "Credit for order ##{self.reference_number}", 
        debit_amounts_attributes: [{amount: self.total_amount_without_discount, account: @accounts_receivable}, {amount: self.stock_cost, account: @cost_of_goods_sold}], 
        credit_amounts_attributes:[{amount: self.total_amount_without_discount, account: @sales}, {amount: self.stock_cost, account: @merchandise_inventory}], 
        employee_id: self.employee_id)

    elsif self.cash? && self.discounted?
      Accounting::Entry.create(entry_type: "cash_order", order_id: self.id, commercial_document_id: self.customer_id, 
        commercial_document_type: self.customer.class, date: self.date, 
        description: "Payment for order ##{self.reference_number} with discount of #{self.total_discount}", 
        debit_amounts_attributes: [{amount: self.total_amount_less_discount, account: @cash_on_hand}, {amount: self.stock_cost, account: @cost_of_goods_sold}], 
        credit_amounts_attributes:[{amount: self.total_amount_less_discount, account: @sales}, {amount: self.stock_cost, account: @merchandise_inventory}],  
        employee_id: self.employee_id)

    elsif self.credit? && self.discounted?
      entry_for_discounted_credit
    end
  end

  def entry_for_discounted_credit
    Accounting::Entry.create(order_id: self.id, commercial_document_id: self.customer_id, 
      commercial_document_type: self.customer.class, date: self.date, 
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

  def set_customer
    if customer_id.nil?
      customer_id = Customer.find_by(first_name: 'Guest').id
    end
  end
end
