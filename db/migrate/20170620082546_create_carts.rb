class CreateCarts < ActiveRecord::Migration[5.1]
  def change
    create_table :carts do |t|
    	t.integer :employee_id, index: true

      t.timestamps
    end
  end
end
