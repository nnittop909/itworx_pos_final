class AddProfilePhotoToMembers < ActiveRecord::Migration[5.1]
  def up
    add_attachment :members, :profile_photo
  end

  def down
    remove_attachment :members, :profile_photo
  end
end
