class AddMemberIdToOrders < ActiveRecord::Migration[5.1]
  def change
  	add_column :orders, :member_id, :integer, index: true, foreign_key: true
  end
end
