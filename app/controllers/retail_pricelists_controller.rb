class RetailPricelistsController < ApplicationController
  def index
    @products = Product.all
    respond_to do |format|
      format.html
      format.pdf do
        pdf = RetailPricelistPdf.new(@products, view_context)
          send_data pdf.render, type: "application/pdf", disposition: 'inline', file_name: "Invoice.pdf"
        pdf.print
      end
    end
  end
end
