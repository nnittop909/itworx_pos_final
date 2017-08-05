class EmployeePolicy < ApplicationPolicy
  def initialize(employee, record)
    @employee = employee
    @record = record
  end
  def new?
    create?
  end
  def create?
    @employee.proprietor?
  end
end
