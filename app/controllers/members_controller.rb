class MembersController < ApplicationController
  autocomplete :member, :full_name, full: true

  def index
    if params[:full_name].present?
      @members = User.customer.search_by_name(params[:full_name]).page(params[:page]).per(30)
    else
      @members = User.customer.all.page(params[:page]).per(30)
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
    @members = User.customer.all
    @names = @members.map { |m| m.full_name }
    render json: @names
  end

  def new
    @member = Member.new
    @member.build_address
  end

  def create
    @members = Member.all
    @member = Member.create(member_params)
  end

  def edit
    @member = User.customer.find(params[:id])
    @address = @member.address
  end

  def update
    @member = User.customer.find(params[:id])
    @member.update_attributes(member_params)
  end

  def show
    @member = User.customer.find(params[:id])
  end

  def info
    @member = User.customer.find(params[:id])
  end

  def purchases
    @member = User.customer.find(params[:id])
    @cash_transactions = @member.orders.order(date: :desc).page(params[:page]).per(50)
  end

  def account_details
    @member = User.customer.find(params[:id])
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
  def member_params
    params.require(:member).permit(:member_type, :first_name, :last_name, :email, :password, :password_confirmation, :role, :mobile, address_attributes:[:id, :house_number, :street, :barangay, :municipality, :province, :id ])
  end
end
