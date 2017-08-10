class AddMemberIdToAddresses < ActiveRecord::Migration[5.1]
  def change
  	add_column :addresses, :member_id, :integer, index: true, foreign_key: true
  end
end
