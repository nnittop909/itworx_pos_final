module Accounting
  class EntryPolicy < ApplicationPolicy
    def initialize(employee, entry)
      @employee = employee
      @entry = entry
    end
    def index?
      @employee.bookkeeper? || @employee.proprietor?
    end
    def new?
      create?
    end
    def create?
      @employee.bookkeeper? || @employee.proprietor?
    end
  end
end
