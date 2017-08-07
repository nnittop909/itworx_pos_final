class AddItemableToLineItems < ActiveRecord::Migration[5.1]
  def change
    add_column :line_items, :itemable_id, :integer
    add_index :line_items, :itemable_id
    add_column :line_items, :itemable_type, :string
    add_index :line_items, :itemable_type
  end
end
