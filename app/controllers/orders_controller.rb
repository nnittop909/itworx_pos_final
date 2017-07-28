class OrdersController < ApplicationController
  autocomplete :member, :full_name, full: true

  def index 
    @orders = Order.all.page(params[:page]).per(50)
    if params[:name]
      @orders = Order.text_search(params[:name]).page(params[:page]).per(50)
    end
  end
  
  def new
    @cart = current_cart
    @catering_cart = current_catering_cart
    if @cart.line_items.empty? && @catering_cart.catering_line_items.empty?
      if request.referer == store_index_url
        redirect_to store_index_url, notice: "Your cart is empty"
      elsif request.referer == wholesales_url
        redirect_to wholesales_url, notice: "Your cart is empty"
      elsif request.referer == caterings_url
        redirect_to caterings_url, notice: "Your cart is empty"
      end
      return
    end
    @order = Order.new
    @order.build_discount
  end

  def create
    @order = Order.new(order_params)
    @order.employee = current_user
    @order.add_line_items_from_cart(current_cart)
    @order.add_line_items_from_catering_cart(current_catering_cart)
    respond_to do |format|
      if @order.save
        @order.create_entry
        Cart.destroy(session[:cart_id])
        session[:cart_id] = nil
        format.html do
          if @order.credit?
            @order.unpaid!
            if @order.retail? || @order.wholesale?
              @order.subscribe_to_program
            end
            redirect_to print_order_url(@order), notice: 'Credit transaction saved successfully.'
          else
            @order.paid!
            redirect_to print_order_url(@order), notice: 'Thank you for your order.'
          end
        end
        format.json { render json: @order, status: :created, location: @order }
      else
        @cart = current_cart
        format.html { render action: "new" }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
    InvoiceNumber.new.generate_for(@order)
  end

  def retail
    @total_sales = Order.created_between({from_date: Time.now.beginning_of_day, to_date: Time.now.end_of_day}).sum(&:total_amount_less_discount)
    @cash_sales = Order.created_between({from_date: Time.now.beginning_of_day, to_date: Time.now.end_of_day}).cash.sum(&:total_amount_less_discount)
    @credit_sales = Order.created_between({from_date: Time.now.beginning_of_day, to_date: Time.now.end_of_day}).credit.sum(&:total_amount_less_discount)
    if params[:full_name].present?
      @orders = Order.retail.text_search(params[:full_name]).page(params[:page]).per(50)
    else
      @orders = Order.retail.includes(:member, :invoice_number).order(id: :desc).all.page(params[:page]).per(50)
    end
  end

  def wholesale
    @total_sales = Order.created_between({from_date: Time.now.beginning_of_day, to_date: Time.now.end_of_day}).sum(&:total_amount_less_discount)
    @cash_sales = Order.created_between({from_date: Time.now.beginning_of_day, to_date: Time.now.end_of_day}).cash.sum(&:total_amount_less_discount)
    @credit_sales = Order.created_between({from_date: Time.now.beginning_of_day, to_date: Time.now.end_of_day}).credit.sum(&:total_amount_less_discount)
    if params[:full_name].present?
      @orders = Order.wholesale.text_search(params[:full_name]).page(params[:page]).per(50)
    else
      @orders = Order.wholesale.includes(:member, :invoice_number).order(id: :desc).all.page(params[:page]).per(50)
    end
  end

  def show
    @order = Order.find(params[:id])
    @line_items = @order.line_items
    respond_to do |format|
      format.html
      format.pdf do
        pdf = InvoicePdf.new(@order, @line_items, view_context)
          send_data pdf.render, type: "application/pdf", disposition: 'inline', file_name: "Invoice.pdf"
        pdf.print
      end
    end
  end

  def scope_to_date
    @from_date = params[:from_date] ? DateTime.parse(params[:from_date]) : DateTime.now.beginning_of_day
    @to_date = params[:to_date] ? DateTime.parse(params[:to_date]) : DateTime.now.end_of_day
    @orders = Order.created_between({from_date: @from_date.yesterday.end_of_day, to_date: @to_date})
    respond_to do |format|
      format.html
      format.pdf do
        pdf = OrdersPdf.new(@orders, @from_date, @to_date, view_context)
          send_data pdf.render, type: "application/pdf", disposition: 'inline', file_name: "Purchases Report.pdf"
      end
    end
  end

  def scope_to_date_summary
    @from_date = params[:from_date] ? DateTime.parse(params[:from_date]) : Time.now.beginning_of_day
    @to_date = params[:to_date] ? DateTime.parse(params[:to_date]) : Time.now.end_of_day
    @stocks = Stock.created_between(params[:from_date], params[:to_date])
    @orders = Order.created_between({from_date: @from_date.yesterday.end_of_day, to_date: @to_date.end_of_day})
    respond_to do |format|
      format.html
      format.pdf do
        pdf = SummaryOfSalesPdf.new(@stocks, @orders, @from_date, @to_date, view_context)
          send_data pdf.render, type: "application/pdf", disposition: 'inline', file_name: "Summary Report.pdf"
      end
    end
  end

  def guest
    @order = Order.new(order_params)
    @order.add_line_items_from_cart(current_cart)
    @order.member = Member.find_by_first_name('Guest')
    @order.save
    redirect_to store_url, notice:
    'Thank you for your order.'
  end

  def print_invoice
    @order = Order.find(params[:id])
    @line_items = @order.line_items + @order.catering_line_items
    respond_to do |format|
      format.pdf do
        pdf = InvoicePdf.new(@order, @line_items, view_context)
          send_data pdf.render, type: "application/pdf", disposition: 'inline', file_name: "Invoice No.#{@order.invoice_number}.pdf"
        pdf.autoprint
      end
    end
  end

  def print_official_receipt
    @order = Order.find(params[:id])
    @line_items = @order.line_items
    OfficialReceiptNumber.new.generate_for(@order)
    respond_to do |format|
      forma t.pdf do
        pdf = PosReceiptPdf.new(@order, @line_items, view_context)
          send_data pdf.render, type: "application/pdf", disposition: 'inline', file_name: "Invoice No.#{@order.invoice_number}.pdf"
        pdf.print
      end
    end
  end

  def print
    @order = Order.find(params[:id])
    @line_items = @order.line_items
    respond_to do |format|
      format.html
      format.pdf do
        pdf = PosReceiptPdf.new(order, order.line_items, view_context)
        pdf.print
      end
    end
  end

  def return_order
    @order = Order.find(params[:order_id])
    @order.employee = current_user
    @order.return_line_items_to_stock!
    @order.destroy
    redirect_to store_index_url, alert: 'Sales Return saved successfully.'
  end

  def destroy 
    @order = Order.find(params[:id])
    if @order.line_items.empty?
      @order.destroy
      redirect_to retail_orders_url, alert: "Order deleted successfully."
    else
      @order.return_line_items_to_stock!
      redirect_to @order, alert: "Order can not be deleted. Line Items are present."
    end 
  end
  private
  def order_params
    params.require(:order).permit(:order_type, :user_id, :cash_tendered, :change, :pay_type, :delivery_type, :date, :discounted, discount_attributes:[:amount])
  end
end
