class AddProfilePhotoToCustomers < ActiveRecord::Migration[5.1]
  def up
    add_attachment :customers, :profile_photo
  end

  def down
    remove_attachment :customers, :profile_photo
  end
end
