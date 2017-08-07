class CreateStockTransfers < ActiveRecord::Migration[5.1]
  def change
    create_table :stock_transfers do |t|
      t.integer :entry_id 
      t.integer :stock_id
      t.integer :supplier_id
      t.integer :employee_id
      t.datetime :date
      t.decimal :amount
      t.decimal :quantity
      t.string :remarks

      t.timestamps
    end
  end
end
