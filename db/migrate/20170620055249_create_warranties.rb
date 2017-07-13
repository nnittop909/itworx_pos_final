class CreateWarranties < ActiveRecord::Migration[5.1]
  def change
    create_table :warranties do |t|
      t.string :description
      t.integer :business_id, index: true

      t.timestamps
    end
  end
end
