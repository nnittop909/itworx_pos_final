class StockPolicy < ApplicationPolicy
  def initialize(employee, stock)
    @employee = employee
    @stock = stock
  end

  def index?
    @employee.stock_custodian? || @employee.proprietor?
  end
end
