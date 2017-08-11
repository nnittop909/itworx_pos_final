class OutOfStockProductsController < ApplicationController
  def index
    @products = Product.out_of_stock
    respond_to do |format|
      format.html
      format.pdf do
        pdf = Stocks::OutOfStockPdf.new(@products, view_context)
            send_data pdf.render, type: "application/pdf", disposition: 'inline', file_name: "Out Stock Products Report.pdf"
        end
    end
  end
end
