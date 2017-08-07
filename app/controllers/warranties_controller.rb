class WarrantiesController < ApplicationController
  def new
    @warranty = Warranty.new
  end

  def create
    @warranty = Warranty.create(warranty_params)
  end
  
  private
  def warranty_params
    params.require(:warranty).permit(:description)
  end
end
