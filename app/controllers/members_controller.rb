class MembersController < ApplicationController
  autocomplete :member, :full_name, full: true

  def index
    if params[:full_name].present?
      @members = Member.search_by_name(params[:full_name]).page(params[:page]).per(30)
    else
      @members = Member.all.page(params[:page]).per(30)
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
    @members = Member.all
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
    @member = Member.find(params[:id])
    @address = @member.address
  end

  def update
    @member = Member.find(params[:id])
    @member.update_attributes(member_params)
  end

  def show
    @member = Member.find(params[:id])
  end

  def info
    @member = Member.find(params[:id])
  end

  def purchases
    @member = Member.find(params[:id])
    @cash_transactions = @member.orders.order(date: :desc).page(params[:page]).per(50)
  end

  def account_details
    @member = Member.find(params[:id])
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
    params.require(:member).permit(:last_name, :first_name, :middle_name, :member_type, :mobile, :profile_photo, address_attributes:[:id, :house_number, :street, :barangay, :municipality, :province, :id ])
  end
end
