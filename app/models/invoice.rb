class Invoice < ApplicationRecord
  belongs_to :invoiceable, polymorphic: true
  def for(invoiceable)
    if invoiceable.credit?
      Invoices::ChargeInvoice.create!(invoiceable_id: invoiceable.id, invoiceable_type: invoiceable.class, number: invoice_number)
    elsif invoiceable.cash?
      Invoices::SalesInvoice.create!(invoiceable_id: invoiceable.id, invoiceable_type: invoiceable.class, number: invoice_number)
    end
  end

  def invoice_number
    if Invoice.last.present?
      "#{Invoice.last.number.succ.rjust(9, '0')}"
    else 
      "#{1.to_s.rjust(8, '0')}"
    end
  end
end
