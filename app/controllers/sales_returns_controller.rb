class SalesReturnsController < ApplicationController

  def return_order
    @order = Order.find(params[:id])
    @order.employee = current_user
    @order.create_entry_for_sales_return
    @order.destroy
    redirect_to store_index_url, alert: 'Sales Return saved successfully.'
  end

  def return_line_item
  	@line_item = LineItem.find(params[:id])
    @line_item.employee = current_user
    @line_item.create_entry_for_sales_return
    @line_item.destroy
    redirect_to store_index_url, alert: 'Sales Return saved successfully.'
  end
end 