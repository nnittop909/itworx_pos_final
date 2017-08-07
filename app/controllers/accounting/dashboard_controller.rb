module Accounting
  class DashboardController < ApplicationController
    def index
      authorize [:accounting, :dashboard]
    end
  end
end
