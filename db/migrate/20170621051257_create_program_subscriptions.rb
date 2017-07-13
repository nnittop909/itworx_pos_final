class CreateProgramSubscriptions < ActiveRecord::Migration[5.1]
  def change
    create_table :program_subscriptions do |t|
      t.integer :member_id, index: true, foreign_key: true
      t.belongs_to :program, index: true, foreign_key: true

      t.timestamps
    end
  end
end
