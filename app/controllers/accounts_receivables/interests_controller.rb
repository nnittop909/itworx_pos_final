module AccountsReceivables
  class InterestsController < ApplicationController
    def create
      # Select member with credits and create entry for daily interests
      Member.with_credits.each do |member|
        Accounting::Interests::Daily.new(member, InterestRate.rate_for(member)).create_entry
      end
      redirect_to credits_url, notice: "Daily Interests added successfully."
    end
  end
end
