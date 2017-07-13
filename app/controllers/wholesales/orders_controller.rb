module Wholesales
  class OrdersController < ApplicationController
    def index
      @orders = Order.all.order(:created_at)
    end
    def new
      @cart = current_cart
        if @cart.line_items.empty?
          redirect_to wholesales_url, notice: "Your cart is empty."
        return
      end
      @order = Order.new
    end
    def create
      @order = Order.new(order_params)
      @order.add_line_items_from_cart(current_cart)
      @order.employee = current_user
      respond_to do |format|
        if @order.save
          @order.wholesale!
          @order.create_entry
          Cart.destroy(session[:cart_id])
          session[:cart_id] = nil
          format.html do
            if @order.credit?
              redirect_to print_order_url(@order), notice: 'Credit transaction saved successfully.'
            else
              redirect_to print_order_url(@order), notice: 'Thank you for your order.'
            end
          end
          format.json { render json: @order, status: :created,
          location: @order }
        else
          @cart = current_cart
          format.html { render action: "new" }
          format.json { render json: @order.errors,
          status: :unprocessable_entity }
        end
      end
      InvoiceNumber.new.generate_for(@order)
    end

    def show
      @order = Order.find(params[:id])
    end

    private
    def order_params
    params.require(:order).permit(:order_type, :user_id, :cash_tendered, :change, :pay_type, :delivery_type, :date, :discounted, discount_attributes:[:amount])
  end
  end
end
