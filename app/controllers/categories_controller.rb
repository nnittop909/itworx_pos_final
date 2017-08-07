class CategoriesController < ApplicationController
  def new
    @category = Category.new
  end

  def create
    @category = Category.create(category_params)
  end

  def edit
    @category = Category.find(params[:id])
  end

  def update
    @category = Category.find(params[:id])
    @category.update_attributes(category_params)
  end

  def destroy 
    @category = Category.find(params[:id])
    @category.destroy
    
  end

  private

  def category_params
    params.require(:category).permit(:name)
  end
end 
