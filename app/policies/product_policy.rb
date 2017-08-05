class ProductPolicy < ApplicationPolicy
  def initialize(employee, product)
    @employee = employee
    @product = product
  end
  def index?
    true
  end
  def new?
    true
  end
  def create?
    true
  end
end
