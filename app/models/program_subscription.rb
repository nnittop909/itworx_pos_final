class ProgramSubscription < ApplicationRecord
  belongs_to :customer
  belongs_to :program

  def create_entry_for_interest_program
    @accounts_receivable = Accounting::Account.find_by(name: "Accounts Receivables Trade - Current")
    @interest_income_from_credit_sales = Accounting::Account.find_by(name: "Interest Income from Credit Sales")
    
    (LineItem.where(pricing_type: "wholesale").credit +  LineItem.where(pricing_type: "retail").credit).each do |line_item|
      date_of_last_payment = line_item.order.customer.credit_payments.last.date
      if line_item.stock.product.program_product? == true
        Accounting::Entry.create(order_id: line_item.order.id, commercial_document_id: line_item.order.customer_id, 
        commercial_document_type: line_item.order.customer.class, date: Time.zone.now, 
        description: "Interest for credit order ##{self.reference_number}", 
        debit_amounts_attributes: [{amount: self.stock_cost, account: @accounts_receivable}], 
        credit_amounts_attributes:[{amount: self.stock_cost, account: @interest_income_from_credit_sales}],  
        employee_id: line_item.order.employee_id)
        
        interest = (line_item.stock.product.program.amount / 100) * line_item.total_price
        line_item.interest_programs.create!(line_item_id: line_item.id, amount: interest)
      end
    end
  end

  def self.create_entry_for_interest_programs
    Customer.has_program_subscriptions.each do |customer|
      customer.line_items.each do |line_item|
        
      end
    end
  end
end
