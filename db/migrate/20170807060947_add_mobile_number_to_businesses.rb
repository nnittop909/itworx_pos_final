class AddMobileNumberToBusinesses < ActiveRecord::Migration[5.1]
  def change
    add_column :businesses, :mobile_number, :string
    add_column :businesses, :email, :string

  end
end
