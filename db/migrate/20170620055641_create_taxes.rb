class CreateTaxes < ActiveRecord::Migration[5.1]
  def change
    create_table :taxes do |t|
      t.string :name
      t.integer :tax_type
      t.decimal :percentage

      t.timestamps
    end
  end
end
