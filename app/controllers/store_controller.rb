class StoreController < ApplicationController
  def index
    if params[:name_and_description].present?
      @stocks = Stock.purchased.search_by_name(params[:name_and_description])
    else
      @stocks = Stock.purchased.all
    end
    authorize :store
    @cart = current_cart
    @line_item = LineItem.new
    @order = Order.new
    @order.build_discount
  end
end
