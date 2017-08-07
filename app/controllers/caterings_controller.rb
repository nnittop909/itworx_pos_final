class CateringsController < ApplicationController
  
  autocomplete :product, :name_and_description, full: true

  def index
    if params[:name_and_description].present?
      @stocks = Stock.purchased.search_by_name(params[:name_and_description])
    else
      @stocks = Stock.purchased.all
    end
    authorize :store
    @cart = current_cart
    @catering_cart = current_catering_cart
    @line_item = LineItem.new
    @catering_line_item = CateringLineItem.new
    @order = Order.new
    @order.build_discount
  end
end
