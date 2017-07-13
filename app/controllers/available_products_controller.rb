class AvailableProductsController < ApplicationController
  def index
    @products = Product.available.all.page(params[:page]).per(30)
  end
end
