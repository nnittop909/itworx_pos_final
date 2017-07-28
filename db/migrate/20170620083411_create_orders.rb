class CreateOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :orders do |t|
      t.string :name
      t.datetime :date
      t.integer :pay_type
      t.integer :delivery_type
      t.integer :order_type
      t.decimal :cash_tendered
      t.decimal :change
      t.decimal :tax_amount
      t.datetime :deleted_at
      t.boolean :discounted,           default: false
      t.string :reference_number
      t.integer :order_type
      t.integer :payment_status
      t.integer :user_id
      t.integer :employee_id
      t.integer :entry_id, foreign_key: true
      t.integer :tax_id

      t.timestamps
    end
    add_index :orders, :deleted_at
    add_index :orders, :user_id
    add_index :orders, :employee_id
    add_index :orders, :entry_id
    add_index :orders, :tax_id
  end
end
