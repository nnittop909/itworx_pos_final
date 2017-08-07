class Discount < ApplicationRecord
  enum discount_type: [:amount, :percent]

  def to_i
    amount
  end
end
