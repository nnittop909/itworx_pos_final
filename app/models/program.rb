class Program < ApplicationRecord
	has_many :products
	has_many :program_subscriptions
	has_many :customers, through: :program_subscriptions
end
