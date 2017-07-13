class CreatePrograms < ActiveRecord::Migration[5.1]
  def change
    create_table :programs do |t|
      t.string :name
      t.decimal :interest_rate
      t.integer :number_of_days

      t.timestamps
    end
  end
end
