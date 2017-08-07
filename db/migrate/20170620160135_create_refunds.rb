class CreateRefunds < ActiveRecord::Migration[5.1]
  def change
    create_table :refunds do |t|
      t.datetime :date
      t.decimal :amount
      t.decimal :quantity
      t.integer :request_status
      t.string :remarks
      t.integer :employee_id
      t.integer :entry_id, foreign_key: true
      t.integer :stock_id

      t.timestamps
    end
    add_index :refunds, :employee_id
    add_index :refunds, :entry_id
    add_index :refunds, :stock_id
  end
end
