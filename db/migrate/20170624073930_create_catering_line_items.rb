class CreateCateringLineItems < ActiveRecord::Migration[5.1]
  def change
    create_table :catering_line_items do |t|
      t.string :name
      t.string :unit
      t.integer :quantity
      t.decimal :unit_cost
      t.decimal :total_cost
      t.integer :catering_cart_id, foreign_key: true
      t.integer :order_id
      t.integer :user_id, foreign_key: true

      t.timestamps
    end
  end
end
