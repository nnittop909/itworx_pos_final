module Stocks
  class RefundsController < ApplicationController

    def new
      @stock = Stock.find(params[:stock_id])
      @refund = @stock.refunds.build
    end

    def create
      @stock = Stock.find(params[:stock_id])
      @refund = @stock.refunds.create(refund_params)
      if @refund.save
        @refund.create_entry_for_stock_return
        redirect_to stocks_path, notice: "Refund successfull."
      else
        render :new
      end
    end

    private
    def refund_params
      params.require(:refund).permit(:stock_id, :amount, :remarks, :quantity, :date)
    end
  end
end
