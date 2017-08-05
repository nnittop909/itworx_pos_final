FactoryGirl.define do
  factory :line_item do
    cart_id 1
    order_id 1
    user_id 1
    stock_id 1
    quantity "9.99"
    unit_cost "9.99"
    total_cost "9.99"
    pricing_type 1
    deleted_at "2017-06-20 16:39:58"
  end
end
