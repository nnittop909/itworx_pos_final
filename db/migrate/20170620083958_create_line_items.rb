class CreateLineItems < ActiveRecord::Migration[5.1]
  def change
    create_table :line_items do |t|
      t.integer :cart_id, foreign_key: true
      t.integer :order_id
      t.integer :customer_id, foreign_key: true
      t.integer :stock_id
      t.decimal :quantity, default: "1.0"
      t.decimal :unit_price
      t.decimal :total_price
      t.integer :pricing_type, default: 0
      t.datetime :deleted_at
      t.integer :itemable_id, index: true
      t.string :itemable_type, index: true
      t.integer :user_id, index: true

      t.timestamps
    end
    add_index :line_items, :cart_id
    add_index :line_items, :customer_id
    add_index :line_items, :stock_id
    add_index :line_items, :deleted_at
  end
end
