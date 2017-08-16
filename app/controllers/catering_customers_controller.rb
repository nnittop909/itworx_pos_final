class CateringCustomersController < ApplicationController

	def new
		@catering_customer = Catering.new
    @catering_customer.build_address
	end

	def create
		@catering_customer = Catering.create(catering_params)
	end

	def edit
    @catering_customer = Catering.find(params[:id])
    @address = @catering_customer.address
  end

  def update
    @catering_customer = Catering.find(params[:id])
    @catering_customer.update_attributes(catering_params)
  end

	private

	def catering_params
		params.require(:catering).permit(:last_name, :first_name, :middle_name, :member_type, :mobile, :profile_photo, address_attributes:[:id, :house_number, :street, :barangay, :municipality, :province, :id ])
	end
end
