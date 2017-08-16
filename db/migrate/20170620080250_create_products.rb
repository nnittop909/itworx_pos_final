class CreateProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :products do |t|
      t.string :name
      t.string :description
      t.string :unit
      t.decimal :retail_price
      t.decimal :wholesale_price
      t.integer :category_id, index: true
      t.boolean :program_product, default: false
      t.integer :program_id, index: true, foreign_key: true
      t.string :name_and_description
      t.decimal :stock_alert_count, default: 1
      t.integer :stock_status

      t.timestamps
    end
    add_index :products, :name
    add_index :products, :description
  end
end
