class ProductsController < ApplicationController

  autocomplete :product, :name_and_description, full: true

  def index
    if params[:name_and_description].present?
      @products = Product.search_by_name(params[:name_and_description]).page(params[:page]).per(40)
    else
      @products = Product.all.order(:name).page(params[:page]).per(40)
      respond_to do |format|
        format.html
        format.pdf do
          pdf = ProductsPdf.new(@products, view_context)
                send_data pdf.render, type: "application/pdf", disposition: 'inline', file_name: "Products Report.pdf"
        end
      end
    end
    authorize Product
  end

  def import
    begin
      Product.import(params[:file])
      redirect_to settings_url, notice: 'Products Imported'
    rescue
      redirect_to settings_url, notice: 'Invalid CSV File.'
    end
  end

  def new
    @product = Product.new
    @product.stocks.build
    authorize @product
  end

  def create
    @products = Product.all
    @product = Product.create(product_params)
    @product.check_stock_status
  end

  def stock_histories
    @product = Product.find(params[:id])
    @stocks = @product.stocks.order(date: :desc).page(params[:page]).per(30)
  end

  def cash_sales
    @product = Product.find(params[:id])
    @sales = @product.line_items.cash
    @results = Kaminari.paginate_array(@sales).page(params[:page]).per(50)
  end

  def credit_sales
    @product = Product.find(params[:id])
    @sales = @product.line_items.credit
    @results = Kaminari.paginate_array(@sales).page(params[:page]).per(50)
  end

  def edit
    @product = Product.find(params[:id])
  end

  def update
    @product = Product.find(params[:id])
    @product.update(product_params)
    @product.check_stock_status
    @product.update_prices
  end

  def scope_to_category
    @products = Product.by_category(params[:category]).page(params[:page]).per(40)
  end

  def reports
    @product = Product.find(params[:id])
    @sales = @product.line_items.credit
    @results = Kaminari.paginate_array(@sales).page(params[:page]).per(50)
  end
  
  def scope_to_date_cash_sales
    @product = Product.find(params[:id])
    @from_date = params[:from_date] ? DateTime.parse(params[:from_date]) : Time.now.yesterday.end_of_day
    @to_date = params[:to_date] ? DateTime.parse(params[:to_date]) : Time.now.end_of_day
    @line_items = @product.line_items.cash.select{|a| a.created_at.between?(@from_date, @to_date) }
    respond_to do |format|
      format.html
      format.pdf do
        pdf = Products::SalesReportPdf.new(@product, @line_items, @from_date, @to_date, view_context)
          send_data pdf.render, type: "application/pdf", disposition: 'inline', file_name: "Sales Report.pdf"
      end
    end
  end
  def scope_to_date_sales
    @product = Product.find(params[:id])
    @from_date = params[:from_date] ? DateTime.parse(params[:from_date]) : Time.zone.now
    @to_date = params[:to_date] ? DateTime.parse(params[:to_date]) : Time.zone.now
    @line_items = @product.line_items.all.created_between({from_date: @from_date, to_date: @to_date})
    respond_to do |format|
      format.html
      format.pdf do
        pdf = Products::SalesReportPdf.new(@product, @line_items, @from_date, @to_date, view_context)
          send_data pdf.render, type: "application/pdf", disposition: 'inline', file_name: "Sales Report.pdf"
      end
    end
  end

  def scope_to_date_credit_sales
    @product = Product.find(params[:id])
    @from_date = params[:from_date] ? DateTime.parse(params[:from_date]) : Time.now.yesterday.end_of_day
    @to_date = params[:to_date] ? DateTime.parse(params[:to_date]) : Time.now.end_of_day
    @orders = @product.line_items.credit.all.created_between({from_date: @from_date, to_date: @to_date})
    respond_to do |format|
      format.html
      format.pdf do
        pdf = OrdersPdf.new(@orders, @from_date, @to_date, view_context)
          send_data pdf.render, type: "application/pdf", disposition: 'inline', file_name: "Sales Report.pdf"
      end
    end
  end

  private
  def product_params
    params.require(:product).permit(:name, :description, :unit, :retail_price, :wholesale_price, :stock_alert_count, :category_id, :program_product, :program_id)
  end
end
