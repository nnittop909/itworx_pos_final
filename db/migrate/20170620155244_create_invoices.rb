class CreateInvoices < ActiveRecord::Migration[5.1]
  def change
    create_table :invoices do |t|
      t.string :number
      t.string :type
      t.integer :invoiceable_id
      t.string :invoiceable_type

      t.timestamps
    end
    add_index :invoices, :type
    add_index :invoices, :invoiceable_id
    add_index :invoices, :invoiceable_type
  end
end
