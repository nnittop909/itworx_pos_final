class CreateCateringCarts < ActiveRecord::Migration[5.1]
  def change
    create_table :catering_carts do |t|
      t.integer :employee_id

      t.timestamps
    end
    add_index :catering_carts, :employee_id
  end
end
