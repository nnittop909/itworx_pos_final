class CreateAmounts < ActiveRecord::Migration[5.1]
  def change
    create_table :amounts do |t|
      t.string :type
      t.decimal :amount, default: 0
      t.references :account, foreign_key: true
      t.references :entry, foreign_key: true

      t.timestamps
    end
    add_index :amounts, :type
  end
end
