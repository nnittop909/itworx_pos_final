module Orders  
  class SalesReturnsController < ApplicationController 
    def destroy 
      @order = Order.find(params[:id])
      @order.employee = current_user
      @order.destroy
      redirect_to retail_orders_url, alert: 'Order cancelled successfully.'
    end 
  end 
end