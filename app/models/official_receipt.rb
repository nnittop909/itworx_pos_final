class OfficialReceipt < ApplicationRecord
	belongs_to :receiptable, polymorphic: true
end
