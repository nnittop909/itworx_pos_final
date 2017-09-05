require 'rake'

task :calculate_interest => :environment do
	customer = Customer.with_credits
	
  customer.each do |c|
  	
  end
end