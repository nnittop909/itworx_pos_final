class CreateDiscounts < ActiveRecord::Migration[5.1]
  def change
    create_table :discounts do |t|
      t.decimal :amount,          default: "0.0"
      t.integer :discount_type
      t.integer :order_id
      t.integer :employee_id

      t.timestamps
    end
    add_index :discounts, :employee_id
  end
end
