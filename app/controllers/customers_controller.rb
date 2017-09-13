class CustomersController < ApplicationController
  autocomplete :customer, :full_name, full: true

  def index
    if params[:full_name].present?
      @members = Customer.search_by_name(params[:full_name]).page(params[:page]).per(30)
    else
      @members = Customer.all.page(params[:page]).per(30)
    end
  end

  def import
    begin
      Member.import(params[:file])
      redirect_to settings_url, notice: 'Members Imported'
    rescue
      redirect_to settings_url, notice: 'Invalid CSV File.'
    end
  end

  def autocomplete
    @members = Customer.all
    @names = @members.map { |m| m.full_name }
    render json: @names
  end

  def new
    @member = Customer.new
    @member.build_address
  end

  def create
    @members = Customer.all
    @member = Customer.create(customer_params)
  end

  def show
    @member = Customer.find(params[:id])
  end

  def info
    @member = Customer.find(params[:id])
  end

  def purchases
    @member = Customer.find(params[:id])
    @cash_transactions = @member.orders.order(date: :desc).page(params[:page]).per(50)
    @catering_expenses = @member.catering_expenses
  end

  def account_details
    @member = Customer.find(params[:id])
    @credit_payments = @member.credit_payments
    respond_to do |format|
      format.html
      format.pdf do 
         pdf = Members::AccountDetailsPdf.new(@member, view_context)
                send_data pdf.render, type: "application/pdf", disposition: 'inline', file_name: "Account Details Report.pdf"
      end
    end
  end

  private
  def customer_params
    params.require(:customer).permit(:last_name, :first_name, :middle_name, :member_type, :type, :mobile, :profile_photo, address_attributes:[:id, :house_number, :street, :barangay, :municipality, :province, :id ])
  end
end
