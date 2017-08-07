class ExpiredProductsController < ApplicationController
  def index
    @stocks = Stock.expired
    respond_to do |format|
      format.html
      format.pdf do
        pdf = Stocks::ExpiredPdf.new(@stocks, view_context)
              send_data pdf.render, type: "application/pdf", disposition: 'inline', file_name: "Expired Stock Report.pdf"
      end
    end
  end
end
