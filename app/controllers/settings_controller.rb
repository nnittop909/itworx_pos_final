class SettingsController < ApplicationController
  def index
  	@categories = Category.order(name: :desc).all
  	@suppliers = Supplier.order(:business_name).all
  	@programs = Program.order(:name).all
  end
end
