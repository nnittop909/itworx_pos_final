class CreateOfficialReceipts < ActiveRecord::Migration[5.1]
  def change
    create_table :official_receipts do |t|
      t.integer :receiptable_id
      t.string :receiptable_type
      t.datetime :date
      t.string :number

      t.timestamps
    end
    add_index :official_receipts, :receiptable_id
    add_index :official_receipts, :receiptable_type
    add_index :official_receipts, :number, unique: true
  end
end
