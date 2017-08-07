class LineItemsController < ApplicationController
  def create
    @cart = current_cart
    @line_item = @cart.line_items.create(line_item_params)
    @line_item.compute_total_price
    respond_to do |format|
      if @line_item.save!
        # @line_item.retail!
        @line_item.stock.product.check_stock_status
        @cart.add_line_item(@line_item)
        if @line_item.retail?
          format.html { redirect_to store_index_url, notice: "Added to cart." }
        elsif @line_item.wholesale?
          format.html { redirect_to wholesales_url, notice: "Added to cart." }
        elsif @line_item.catering?
          format.html { redirect_to caterings_url, notice: "Added to cart." }
        end
        format.js { @current_item = @line_item }
      else
        format.html { redirect_to store_index_url, notice: @line_item.errors }
      end
    end
  end

  def return_line_item
    @line_item = LineItem.find(params[:line_item_id])
    @line_item.employee = current_user
    @line_item.return_quantity_to_stock!
    @line_item.create_entry_for_sales_return
    @line_item.destroy
    redirect_to store_index_url, alert: 'Sales Return saved successfully.'
  end

  def destroy
    @line_item = LineItem.find(params[:id])
    @line_item.destroy
    if request.referer == store_index_url
      redirect_to store_index_url, alert: "Item has been removed."
    elsif request.referer == wholesales_url
      redirect_to wholesales_url, alert: "Item has been removed."
    elsif request.referer == caterings_url
      redirect_to caterings_url, alert: "Item has been removed."
    end
  end

  private
  def line_item_params
    params.require(:line_item).permit(:pricing_type, :user_id, :stock_id, :quantity, :unit_price, :total_price)
  end
end
