class AddLogoToBusiness < ActiveRecord::Migration[5.1]
  def up
    add_attachment :businesses, :logo
  end

  def down
    remove_attachment :businesses, :logo
  end
end
