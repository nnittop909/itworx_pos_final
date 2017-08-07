class CateringCartsController < ApplicationController
  def show
    begin
    @catering_cart = CateringCart.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      logger.error "Attempt to access invalid cart #{params[:id]}"
      redirect_to caterings_url, alert: 'The cart you were looking for could not be found.'
    else
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @catering_cart }
      end
    end
    @order = Order.new
  end

  def destroy
    @catering_cart = current_catering_cart
    @catering_cart.destroy
    session[:catering_cart_id] = nil
    redirect_to caterings_url, alert: "Catering Cart is now empty."
  end
end
