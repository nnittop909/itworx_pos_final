module Owner
  class DashboardPolicy < ApplicationPolicy
    def initialize(employee, dashboard)
      @employee = employee
      @dashboard = dashboard
    end

    def index?
      @employee.proprietor?
    end
  end
end 
