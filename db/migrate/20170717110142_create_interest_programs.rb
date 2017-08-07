class CreateInterestPrograms < ActiveRecord::Migration[5.1]
  def change
    create_table :interest_programs do |t|
    	t.integer :line_item_id, index: true, foreign_key: true
      t.decimal :amount
      t.timestamps
    end
  end
end
