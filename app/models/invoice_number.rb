class InvoiceNumber < ApplicationRecord
  include PgSearch
  pg_search_scope :search_by_name, :against => [:number]
  belongs_to :order
  def generate_for(order)
    if order.invoice_number.blank?
      InvoiceNumber.create!(order_id: order.id, date: Time.zone.now, number: invoice_number)
    else
      return false
    end
  end
  def invoice_number
    if InvoiceNumber.last.present?
      "#{InvoiceNumber.last.number.succ.rjust(8, '0')}"
    else 
      "#{1.to_s.rjust(8, '0')}"
    end
  end
end
