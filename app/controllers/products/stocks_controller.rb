module Products
  class StocksController < ApplicationController
    def new
      @product = Product.find(params[:product_id])
      @stock = @product.stocks.build
    end

    def create
      @product = Product.find(params[:product_id])
      @stock = @product.stocks.create(stock_params)
      @stock.employee = current_user
      if @stock.save
        redirect_to stock_histories_product_path(@product), notice: "New stock saved successfully."
        @stock.create_entry
        @stock.set_stock_status_to_product
        @stock.purchased!
      else
        render :new
      end
    end
    def destroy 
    @stock = Stock.find(params[:id])
    @stock.create_entry_for_return
    @stock.destroy
    redirect_to stocks_url, alert: 'Stock deleted successfully.'
  end
    
    private
    def stock_params
      params.require(:stock).permit(:has_freight, :freight_amount, :discounted, :discount_amount, :payment_type, :supplier_id, :reference_number, :quantity, :date, :total_cost, :serial_number, :expiry_date, :unit_cost, :retail_price, :wholesale_price)
    end
  end
end
