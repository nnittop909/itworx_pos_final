class AddMemberIdToLineItems < ActiveRecord::Migration[5.1]
  def change
  	add_column :line_items, :member_id, :integer, index: true, foreign_key: true
  end
end
