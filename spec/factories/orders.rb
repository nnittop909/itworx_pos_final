FactoryGirl.define do
  factory :order do
    name "MyString"
    date "2017-06-20 16:34:11"
    pay_type 1
    delivery_type 1
    order_type 1
    cash_tendered "9.99"
    change "9.99"
    tax_amount "9.99"
    deleted_at "2017-06-20 16:34:11"
    discounted false
    reference_number "MyString"
    order_type 1
    user_id 1
    employee_id 1
    entry_id 1
    tax_id 1
  end
end
