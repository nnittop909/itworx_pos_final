class CreateOfficialReceiptNumbers < ActiveRecord::Migration[5.1]
  def change
    create_table :official_receipt_numbers do |t|
      t.date :date
      t.string :number
      t.integer :order_id, foreign_key: true

      t.timestamps
    end
    add_index :official_receipt_numbers, :order_id
  end
end
