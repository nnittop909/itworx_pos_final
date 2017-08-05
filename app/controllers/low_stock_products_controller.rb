class LowStockProductsController < ApplicationController
  def index
    @products = Product.low_stock.all.page(params[:page]).per(30)
    respond_to do |format|
      format.html
      format.pdf do
        pdf = Stocks::LowStockPdf.new(@products, view_context)
              send_data pdf.render, type: "application/pdf", disposition: 'inline', file_name: "Low Stock Products Report.pdf"
      end
    end
  end
end
