module Stocks
  class StockTransfersController < ApplicationController

    def new
      @stock = Stock.find(params[:stock_id])
      @stock_transfer = @stock.stock_transfers.build
    end

    def create
      @stock = Stock.find(params[:stock_id])
      @stock_transfer = @stock.stock_transfers.create(stock_transfer_params)
      if @stock_transfer.save
        @stock_transfer.create_entry_for_stock_transfer
        redirect_to stocks_path, notice: "Stock transfer successfull."
      else
        render :new
      end
    end

    private
    def stock_transfer_params
      params.require(:stock_transfer).permit(:stock_id, :employee_id, :supplier_id, :amount, :remarks, :quantity, :date)
    end
  end
end
