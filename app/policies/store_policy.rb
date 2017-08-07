class StorePolicy < ApplicationPolicy
  def initialize(employee, store)
    @employee = employee
    @store = store
  end
  def index?
    @employee.proprietor? || @employee.cashier?
  end
end
