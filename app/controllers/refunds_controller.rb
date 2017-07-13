class RefundsController < ApplicationController
  def index
    @refunds = Refund.all
  end

  def new
    @refund = Refund.new
  end

  def create
    @refund = Refund.create(refund_params)
    @refund.employee = current_user
    if @refund.save
      redirect_to refunds_url, notice: "Refund saved successfully."
    else
      render :new
    end
  end

  private
  def refund_params
    params.require(:refund).permit(:stock_id, :amount, :remarks, :quantity, :date)
  end
end
