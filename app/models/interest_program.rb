class InterestProgram < ApplicationRecord
	belongs_to :line_item

	def total_amount
		all.sum(:amount)
	end
end
