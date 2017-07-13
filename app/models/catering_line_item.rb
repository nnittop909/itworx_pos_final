class CateringLineItem < ApplicationRecord

  belongs_to :catering_cart
  belongs_to :order
  belongs_to :employee, foreign_key: 'user_id'
  belongs_to :member, foreign_key: 'department_id'
  validates :name, :unit, :quantity, :total_cost, presence: true
  before_save :compute_unit_price
  delegate :credit?, to: :order

  def self.credit
      all.select{|a| a.credit? }
  end
  
  def credit?
     order.present? && order.credit?
  end

  def compute_unit_price
    self.unit_cost = self.total_cost / quantity
  end

end
