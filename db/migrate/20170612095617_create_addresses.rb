class CreateAddresses < ActiveRecord::Migration[5.1]
  def change
    create_table :addresses do |t|
    	t.string :house_number
      t.string :street
      t.string :barangay
      t.string :municipality
      t.string :province
      t.belongs_to :user, index: true, foreign_key: true
      
      t.timestamps
    end
  end
end
