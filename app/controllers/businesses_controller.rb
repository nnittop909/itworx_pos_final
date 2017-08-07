class BusinessesController < ApplicationController
  def new
    @business = Business.new
  end

  def create
    @business = Business.create(business_params)
  end

  def edit
    @business = Business.find(params[:id])
  end

  def update
    @business = Business.find(params[:id])
    @business.update(business_params)
  end

  private
  def business_params
    params.require(:business).permit(:name, :mobile_number, :email, :tin, :address, :proprietor, :mobile_number, :email, :logo)
  end
end
