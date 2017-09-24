require 'rake'

task :calculate_interest => :environment do
	customers = Member.with_credits
	accounts_receivables_trade = Accounting::Account.find_by(name: "Accounts Receivables Trade - Current")
  interest_income_from_credit_sales = Accounting::Account.find_by(name: "Interest Income from Credit Sales")

  customers.each do |c|
  	c.line_items.each do |l|
  			program = l.stock.product.program
        interest = (program.interest_rate / 100.0) * l.total_price
        InterestProgram.create(line_item_id: l.id, amount: interest)
        Accounting::Entry.create(commercial_document_id: self.customer_id, 
        commercial_document_type: self.customer.class, date: self.date, 
        description: "Interest of order ##{self.reference_number}.", 
        debit_amounts_attributes: [{amount: interest, account: accounts_receivables_trade}], 
        credit_amounts_attributes:[{amount: interest, account: interest_income_from_credit_sales}], 
        employee_id: self.employee_id)
  	end
  end
end