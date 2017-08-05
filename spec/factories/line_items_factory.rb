FactoryGirl.define do 
	factory :line_item do
	  cart_id nil 
	  order_id nil
	  user_id nil 
	  association :stock
	  unit_price 10 
	  total_price 10
	  pricing_type 'retail'
	  quantity 1
	end 
end 