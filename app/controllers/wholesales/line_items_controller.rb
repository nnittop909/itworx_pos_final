module Wholesales
  class LineItemsController < ApplicationController
    def create
      @cart = current_cart
      @line_item = @cart.line_items.create(line_item_params)
      respond_to do |format|
        if @line_item.save
          @line_item.wholesale!
          @cart.add_line_item(@line_item)
          format.html { redirect_to wholesales_url }
          format.js   { @current_item = @line_item }
        else
          format.html { redirect_to wholesales_url }
        end
      end
    end

    def destroy
      @cart = LineItem.find(params[:id])
      @cart.destroy
      redirect_to wholesales_url
    end

    private
    def line_item_params
      params.require(:line_item).permit(:user_id, :stock_id, :quantity, :unit_cost, :total_cost)
    end
  end
end
