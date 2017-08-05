FactoryGirl.define do 
	factory :stock do 
		quantity 10
		supplier
		unit_cost 1
		total_cost 10
		retail_price 10
		wholesale_price 10
	end
end