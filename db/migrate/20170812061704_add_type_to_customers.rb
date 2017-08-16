class AddTypeToCustomers < ActiveRecord::Migration[5.1]
  def change
    add_column :customers, :type, :string
  end
end
