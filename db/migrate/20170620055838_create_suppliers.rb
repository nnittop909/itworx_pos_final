class CreateSuppliers < ActiveRecord::Migration[5.1]
  def change
    create_table :suppliers do |t|
      t.string :business_name
      t.string :owner
      t.string :address
      t.string :mobile_number

      t.timestamps
    end
  end
end
