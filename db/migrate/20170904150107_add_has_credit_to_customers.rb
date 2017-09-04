class AddHasCreditToCustomers < ActiveRecord::Migration[5.1]
  def change
  	add_column :customers, :has_credit, :boolean, default: false
  end
end
