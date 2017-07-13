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
  	self.stock.unit_price
  end

  def in_stock_less_quantity
  	in_stock - quantity
  end

  def refund_amount
  	(in_stock * stock_price) - ((in_stock * stock_price)*0.2)
  end

  def wholesale_quantity
    (self.quantity/self.stock.product.unit_quantity).to_i
  end

  def retail_quantity
    (((self.quantity/self.stock.product.unit_quantity).modulo(1)) * self.stock.product.unit_quantity).to_i
  end

  def converted_in_stock_quantity
    if (self.stock.product.unit_quantity && self.stock.product.highest_unit).present?
      if retail_quantity != 0
        "#{wholesale_quantity} #{self.stock.product.highest_unit}/s" + " & " + "#{retail_quantity} #{self.stock.product.unit}"
      else
        "#{wholesale_quantity}  #{self.stock.product.highest_unit}/s"
      end
    else
      "#{self.quantity} #{self.stock.product.unit}"
    end
  end

  def create_entry_for_stock_return
    @cash_on_hand = Accounting::Account.find_by(name: "Cash on Hand")
    @merchandise_inventory = Accounting::Account.find_by(name: "Merchandise Inventory")

  	if self.quantity == in_stock
  		Accounting::Entry.create!(commercial_document_id: self.id, commercial_document_type: self.class, 
        date: self.date, description: "Returned stock on #{self.stock.product.name_and_description} with a quantity of #{self.converted_in_stock_quantity}", 
        debit_amounts_attributes: [amount: self.amount, account: @cash_on_hand], 
        credit_amounts_attributes:[amount: self.amount, account: merchandise_inventory],  
        employee_id: self.employee_id)
  		self.stock.returned!

  	elsif self.quantity < in_stock
  		Accounting::Entry.create!(commercial_document_id: self.id, commercial_document_type: self.class, 
        date: self.date, description: "Returned stock on #{self.stock.product.name_and_description} with a quantity of #{self.converted_in_stock_quantity}", 
        debit_amounts_attributes: [amount: self.amount, account: @cash_on_hand], 
        credit_amounts_attributes:[amount: self.amount, account: @merchandise_inventory],  
        employee_id: self.employee_id)
  		self.stock.update_attributes!(quantity: in_stock_less_quantity)
  	end
  end

end
