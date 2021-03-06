class IrregularInterestRatesController < ApplicationController

  def new
    @interest_rate = Accounting::InterestRates::Irregular.new
  end

  def create
    @interest_rate = Accounting::InterestRates::Irregular.create(interest_rate_params)
    if @interest_rate.save
      redirect_to settings_url, notice: "Interest Rate created successfully."
    else
      render :new
    end
  end

  def edit
    @interest_rate = InterestRate.find(params[:id])
  end

  def update
    @interest_rate = InterestRate.find(params[:id])
    @interest_rate.update(interest_rate_params)
  end

  private
  def interest_rate_params
    params.require(:accounting_interest_rates_irregular).permit(:rate)
  end
end
