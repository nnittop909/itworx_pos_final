class OfficialReceiptNumber < ApplicationRecord
  belongs_to :order

  def generate_for(order)
    if order.official_receipt_number.blank?
      OfficialReceiptNumber.create(order_id: order.id, date: Time.zone.now, number: number)
    else
      return false
    end
  end
  def self.with_orders
    !all.where(order_id: nil)
  end
  def number
  "#{self.id.to_s.rjust(8, '0')}"
end
end
