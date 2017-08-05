FactoryGirl.define do
  factory :refund do
    date "2017-06-21 00:01:35"
    amount "9.99"
    quantity "9.99"
    request_status 1
    remarks "MyString"
    employee_id 1
    entry_id 1
    stock_id 1
  end
end
