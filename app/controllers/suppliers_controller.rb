class SuppliersController < ApplicationController
  autocomplete :supplier, :owner, full: true

	def index
		if params[:owner].present?
      @suppliers = Supplier.search_by_name(params[:owner])
    else
      @suppliers = Supplier.order(:business_name).all
    end
	end

	def new
		@supplier = Supplier.new
	end

	def create
		@supplier = Supplier.create(supplier_params)
	end

	def edit
		@supplier = Supplier.find(params[:id])
	end

	def update
		@supplier = Supplier.find(params[:id])
		@supplier.update(supplier_params)
	end
	def show 
		@supplier = Supplier.find(params[:id])
	end

	def cash_stocks
		@supplier = Supplier.find(params[:id])
		@cash_stocks = @supplier.stocks.cash.all.page(params[:page]).per(30)
	end

	def credit_stocks
		@supplier = Supplier.find(params[:id])
		@credit_stocks = @supplier.stocks.credit.all.page(params[:page]).per(30)
	end
	def credit_payments
		@supplier = Supplier.find(params[:id])
		@credit_payments = @supplier.credit_payments.page(params[:page]).per(30)
	end

	private

	def supplier_params
		params.require(:supplier).permit(:business_name, :owner, :mobile_number, :address)
	end
end
