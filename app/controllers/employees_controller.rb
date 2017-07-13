class EmployeesController < ApplicationController
  def new
    @employee = Employee.new
    authorize @employee
  end
  def create
    @employee = Employee.create(employee_params)
    authorize @employee
    if @employee.save
      redirect_to settings_url, notice: 'Employee registered successfully.'
    else
      render :new
    end
  end
  def show
    @employee = current_employee
  end

  private
  def employee_params
    params.require(:employee).permit(:first_name, :last_name, :role, :email, :password, :password_confirmation, :profile_photo)
  end
end
