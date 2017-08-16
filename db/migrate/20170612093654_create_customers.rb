class CreateCustomers < ActiveRecord::Migration[5.1]
  def change
    create_table :customers do |t|
      t.string :last_name
      t.string :first_name
      t.string :middle_name
      t.string :full_name
      t.integer :member_type
      t.string :mobile

      t.timestamps
    end
  end
end
