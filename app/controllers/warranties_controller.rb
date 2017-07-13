class WarrantiesController < ApplicationController
  def new
    @warranty = Warranty.new
  end
  def create
    @warranty = Warranty.create(warranty_params)
    if @warranty.save
      redirect_to settings_url, notice: 'Warranty text set successfully.'
    else
      render :new
    end
  end
  private
  def warranty_params
    params.require(:warranty).permit(:description)
  end
end
