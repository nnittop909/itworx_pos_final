class DepartmentsController < ApplicationController

	def new
		@department = Department.new
    @department.build_address
	end

	def create
		@department = Department.create(department_params)
	end

	def edit
		@department = User.customer.find(params[:id])
		@address = @department.address
	end

	def update
		@department = User.customer.find(params[:id])
		@department.update(department_params)
	end

	private

	def department_params
		params.require(:department).permit(:member_type, :first_name, :last_name, :email, :password, :password_confirmation, :role, :mobile, address_attributes:[:id, :house_number, :street, :barangay, :municipality, :province, :id ])
	end
end
