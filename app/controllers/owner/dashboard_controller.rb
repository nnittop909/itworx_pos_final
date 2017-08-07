module Owner
  class DashboardController < ApplicationController
    def index
      authorize [:owner, :dashboard]
    end
  end
end
