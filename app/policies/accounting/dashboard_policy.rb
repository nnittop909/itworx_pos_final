module Accounting
  class DashboardPolicy < ApplicationPolicy
    def initialize(employee, dashboard)
      @employee = employee
      @dashboard = dashboard
    end
    def index?
      @employee.bookkeeper? || @employee.accountant?
    end
  end
end 
