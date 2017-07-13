class CreateInvoiceNumbers < ActiveRecord::Migration[5.1]
  def change
    create_table :invoice_numbers do |t|
      t.datetime :date
      t.string :number
      t.integer :order_id, foreign_key: true

      t.timestamps
    end
    add_index :invoice_numbers, :order_id
  end
end
