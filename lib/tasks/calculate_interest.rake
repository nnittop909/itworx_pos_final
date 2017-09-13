require 'rake'

task :calculate_interest => :environment do
	customers = Customer.with_credits
	accounts_receivables_trade = Accounting::Account.find_by(name: "Accounts Receivables Trade - Current")
  interest_income_from_credit_sales = Accounting::Account.find_by(name: "Interest Income from Credit Sales")
  feeds_program = Program.find_by(name: "Feeds")
  regular_program = Program.find_by(name: "Regular(Groceries)")

  customers.each do |c|
  	c.line_items.each do |l|
  		if l.stock.product.program.id == feeds_program.id
  			program = l.stock.product.program
        interest = (program.interest_rate / 100.0) * l.total_price
        InterestProgram.create(line_item_id: l.id, amount: interest)
        Accounting::Entry.create(order_id: self.id, commercial_document_id: self.customer_id, 
        commercial_document_type: self.customer.class, date: self.date, 
        description: "Interest of order ##{self.reference_number}.", 
        debit_amounts_attributes: [{amount: interest, account: accounts_receivables_trade}], 
        credit_amounts_attributes:[{amount: interest, account: interest_income_from_credit_sales}], 
        employee_id: self.employee_id)
      elsif l.stock.product.program.id == regular_program.id
      	program = l.stock.product.program
        interest = (program.interest_rate / 100.0) * l.total_price
        InterestProgram.create(line_item_id: l.id, amount: interest)
        Accounting::Entry.create(order_id: self.id, commercial_document_id: self.customer_id, 
        commercial_document_type: self.customer.class, date: self.date, 
        description: "Interest of order ##{self.reference_number}.", 
        debit_amounts_attributes: [{amount: interest, account: accounts_receivables_trade}], 
        credit_amounts_attributes:[{amount: interest, account: interest_income_from_credit_sales}], 
        employee_id: self.employee_id)
      end
  	end
  end
end