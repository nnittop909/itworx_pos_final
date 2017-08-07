class CreateAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :accounts do |t|
      t.string :name
      t.string :code
      t.string :type
      t.string :definition
      t.boolean :contra
      t.integer :main_account_id
      t.integer :status, default: 0

      t.timestamps
    end
    add_index :accounts, :main_account_id
  end
end
