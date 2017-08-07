module Accounting
  class CreditPaymentsController < ApplicationController

    def new
      @line_item = LineItem.find(params[:line_item_id])
      @entry = Accounting::Entry.new
      authorize @entry
      @entry.debit_amounts.build
      @entry.credit_amounts.build
    end

    def create
      @line_item = LineItem.find(params[:line_item_id])
      @entry = Accounting::Entry.create(entry_params)
      @entry.commercial_document = @line_item.order
      @entry.recorder = current_user
      if @entry.save
        @line_item.cash!
        redirect_to @line_item.stock.product, notice: "Payment saved successfully."
      else
        render :new
      end
      authorize @entry
    end

    def show
      @entry = Accounting::Entry.find(params[:id])
    end

    private
    def entry_params
      params.require(:accounting_entry).permit(:date, :description, :reference_number, debit_amounts_attributes:[:amount, :account], credit_amounts_attributes:[:amount, :account])
    end
  end
end
