FactoryGirl.define do
  factory :stock do
    name "MyString"
    date "2017-06-20 16:19:53"
    quantity "9.99"
    purchase_price "9.99"
    retail_price "9.99"
    wholesale_price "9.99"
    expiry_date "2017-06-20"
    serial_number "MyString"
    reference_number "MyString"
    payment_type 1
    merged false
    discounted false
    discount_amount "9.99"
    has_freight false
    freight_amount "9.99"
    stock_type 1
    product_id 1
    supplier_id 1
    entry_id 1
    employee_id 1
  end
end
