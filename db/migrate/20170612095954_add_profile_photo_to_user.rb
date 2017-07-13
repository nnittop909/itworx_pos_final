class AddProfilePhotoToUser < ActiveRecord::Migration[5.1]
  def up
    add_attachment :users, :profile_photo
  end

  def down
    remove_attachment :users, :profile_photo
  end
end
