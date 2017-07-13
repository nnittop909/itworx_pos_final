class ProgramSubscription < ApplicationRecord
  belongs_to :member, class_name: "User::Member", foreign_key: "member_id"
  belongs_to :program
end
