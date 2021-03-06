class Refund < ApplicationRecord
  belongs_to :stock
  belongs_to :employee
  validates :date, :stock_id, :amount, :quantity, presence: true
  validates :amount, :quantity, numericality: true
  
  def self.total_amount
    all.sum(:amount)
  end

  def in_stock
  	self.stock.in_stock
  end

  def stock_price
  	self.stock.unit_cost
  end

  def in_stock_less_quantity
  	in_stock - quantity
  end

  def refund_amount
  	(in_stock * stock_price) - ((in_stock * stock_price)*0.2)
  end

  def create_entry_for_stock_return
    @cash_on_hand = Accounting::Account.find_by(name: "Cash on Hand - Teller")
    @merchandise_inventory = Accounting::Account.find_by(name: "Merchandise Inventory")

  	if self.quantity == in_stock
  		Accounting::Entry.create!(commercial_document_id: self.id, commercial_document_type: self.class, 
        date: self.date, description: "Return of stock (#{self.stock.product.name_and_description}) to #{self.stock.supplier.business_name} with a quantity of #{self.quantity} #{self.stock.product.unit}", 
        debit_amounts_attributes: [amount: self.amount, account: @cash_on_hand], 
        credit_amounts_attributes:[amount: self.amount, account: @merchandise_inventory],  
        employee_id: self.employee_id)
  		self.stock.returned!

  	elsif self.quantity < in_stock
  		Accounting::Entry.create!(commercial_document_id: self.id, commercial_document_type: self.class, 
        date: self.date, description: "Return of stock (#{self.stock.product.name_and_description}) to #{self.stock.supplier.business_name} with a quantity of #{self.quantity} #{self.stock.product.unit}", 
        debit_amounts_attributes: [amount: self.amount, account: @cash_on_hand], 
        credit_amounts_attributes:[amount: self.amount, account: @merchandise_inventory],  
        employee_id: self.employee_id)
  		self.stock.update_attributes!(quantity: in_stock_less_quantity)
  	end
  end

end
