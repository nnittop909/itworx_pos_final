class CreateEntries < ActiveRecord::Migration[5.1]
  def change
    create_table :entries do |t|
      t.datetime :date
      t.string :description
      t.integer :commercial_document_id
      t.string :commercial_document_type
      t.integer :customer_id
      t.integer :order_id, foreign_key: true
      t.integer :stock_id, foreign_key: true
      t.integer :employee_id, index: true
      t.string :reference_number, unique: true
      t.integer :entry_type

      t.timestamps
    end
    add_index :entries, :commercial_document_id
    add_index :entries, :commercial_document_type
    add_index :entries, :customer_id
  end
end
