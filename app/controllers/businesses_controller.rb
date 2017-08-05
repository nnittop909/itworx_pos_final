class BusinessesController < ApplicationController
  def new
    @business = Business.new
  end

  def create
    @business = Business.create(business_params)
    if @business.save
      redirect_to settings_url, notice: "Business information saved successfully."
    else
      render :new
    end
  end

  def edit
    @business = Business.find(params[:id])
  end

  def update
    @business = Business.find(params[:id])
    @business.update(business_params)
    if @business.save
      redirect_to settings_url, notice: 'Business information updated successfully.'
    else
      render :edit
    end
  end

  private
  def business_params
    params.require(:business).permit(:name, :tin, :address, :proprietor, :mobile_number, :email, :logo)
  end
end
