class CreateStocks < ActiveRecord::Migration[5.1]
  def change
    create_table :stocks do |t|
      t.string :name
      t.datetime :date
      t.decimal :quantity,            precision:8, scale:2
      t.decimal :unit_cost
      t.decimal :total_cost
      t.decimal :retail_price
      t.decimal :wholesale_price
      t.date :expiry_date
      t.string :serial_number
      t.string :reference_number
      t.integer :payment_type,        default: 0
      t.boolean :merged,              default: false
      t.boolean :discounted,          default: false
      t.decimal :discount_amount,     default: "0.0"
      t.boolean :has_freight,         default: false
      t.decimal :freight_amount,      default: "0.0"
      t.integer :stock_type
      t.integer :product_id, foreign_key: true
      t.integer :supplier_id
      t.integer :entry_id, foreign_key: true
      t.integer :employee_id

      t.timestamps
    end
    add_index :stocks, :product_id
    add_index :stocks, :supplier_id
    add_index :stocks, :entry_id
    add_index :stocks, :employee_id
  end
end
