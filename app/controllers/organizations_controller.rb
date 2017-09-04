class OrganizationsController < ApplicationController

	def new
		@organization = Organization.new
    @organization.build_address
	end

	def create
		@organization = Organization.create(organization_params)
	end

	def edit
    @organization = Organization.find(params[:id])
    @address = @organization.address
  end

  def update
    @organization = Organization.find(params[:id])
    @organization.update_attributes(organization_params)
  end

	private

	def organization_params
		params.require(:organization).permit(:last_name, :first_name, :middle_name, :member_type, :mobile, :profile_photo, address_attributes:[:id, :house_number, :street, :barangay, :municipality, :province, :id ])
	end
end
