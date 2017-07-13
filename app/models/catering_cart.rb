class CateringCart < ApplicationRecord
	belongs_to :employee
  has_many :catering_line_items, dependent: :destroy

  def total_catering_line_items
  	self.catering_line_items.to_a.sum { |item| item.total_cost }
  end
end
