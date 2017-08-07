class StocksController < ApplicationController
  autocomplete :stock, :name_and_description, full: true
  def index
    if params[:name_and_description]
      @available = Stock.available.search_by_name(params[:name_and_description])
      @stocks = Kaminari.paginate_array(@available).page(params[:page]).per(50)
    else
      @available = Stock.available
      @stocks = Kaminari.paginate_array(@available).page(params[:page]).per(50)
    end
  end

  def expired
    @expired = Stock.expired
    @stocks = Kaminari.paginate_array(@expired).page(params[:page]).per(50)
  end

  def out_of_stock
    @out_of_stock = Stock.out_of_stock
    @stocks = Kaminari.paginate_array(@out_of_stock).page(params[:page]).per(50)
  end

  def returned
    @returned = Refund.all
    @stocks = Kaminari.paginate_array(@returned).page(params[:page]).per(50)
  end

  def forwarded
    @forwarded = StockTransfer.all
    @stocks = Kaminari.paginate_array(@forwarded).page(params[:page]).per(50)
  end

  def discontinued
    @discontinued = Stock.discontinued
    @stocks = Kaminari.paginate_array(@discontinued).page(params[:page]).per(50)
  end

  def discontinue
    @stock = Stock.find(params[:stock_id])
    @stock.discontinued!
    @stock.create_expense_from_expired_stock
    redirect_to stocks_path, notice: 'Stock discontinued successfully.'
  end

  def continue
    @stock = Stock.find(params[:stock_id])
    @stock.purchased!
    @stock.remove_expense_from_expired_stock
    redirect_to stocks_path, notice: 'Stock set to active successfully.'
  end

  def new
    @stock = Stock.new
  end

  def create
    @stock = Stock.create(stock_params)
    @stock.employee = current_user
    if @stock.save
      redirect_to stocks_url, notice: "New stock saved successfully."
      if @stock.received?
        @stock.set_stock_status_to_product
        @stock.purchased!
      elsif !@stock.received?
        @stock.create_entry
        @stock.set_stock_status_to_product
        @stock.purchased!
      end
    else
      render :new
    end
  end

  def show
    @stock = Stock.find(params[:id])
  end

  def scope_to_date
    @stocks = Stock.created_between(params[:from_date], params[:to_date])
    @from_date = params[:from_date] ? Time.parse(params[:from_date]) : Time.now.beginning_of_day
    @to_date = params[:to_date] ? Time.parse(params[:to_date]) : Time.now.end_of_day
    respond_to do |format|
      format.html
      format.pdf do
        pdf = StocksPdf.new(@stocks, @from_date, @to_date, view_context)
          send_data pdf.render, type: "application/pdf", disposition: 'inline', file_name: "Purchases Report.pdf"
      end
    end
  end

  def destroy 
    @stock = Stock.find(params[:id])
    @stock.employee = current_user
    if @stock.line_items.blank?
      @stock.destroy
      @stock.entry.destroy
      redirect_to stocks_url, alert: 'Stock deleted successfully.'
    else
      redirect_to stock_path(@stock), alert: "Unable to delete stock because there are orders associated with it. Discontinue instead!"
    end
  end

  private
  def stock_params
    params.require(:stock).permit(:received, :has_freight, :freight_amount, :discounted, :discount_amount, :payment_type, :supplier_id, :reference_number, :product_id, :quantity, :date, :unit_cost, :serial_number, :expiry_date, :total_cost, :retail_price, :wholesale_price)
  end
end
