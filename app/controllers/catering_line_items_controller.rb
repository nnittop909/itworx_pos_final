class CateringLineItemsController < ApplicationController

	def new
		@catering_cart = current_catering_cart
		@catering_line_item = @catering_cart.catering_line_items.build
	end

	def create
    @catering_cart = current_catering_cart
    @catering_line_item = @catering_cart.catering_line_items.create(catering_line_item_params)
  end

  def destroy
  	@catering_line_item = CateringLineItem.find(params[:id])
    @catering_line_item.destroy
    redirect_to caterings_url
  end

	private

	def catering_line_item_params
		params.require(:catering_line_item).permit(:name, :unit, :quantity, :unit_cost, :total_cost)
	end
end