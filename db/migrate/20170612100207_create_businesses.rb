class CreateBusinesses < ActiveRecord::Migration[5.1]
  def change
    create_table :businesses do |t|
    	t.string :name
      t.string :tin
      t.boolean :vat
      t.string :address
      t.string :proprietor
      
      t.timestamps
    end
  end
end
