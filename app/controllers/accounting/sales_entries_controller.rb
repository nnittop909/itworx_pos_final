module Accounting
  class SalesEntriesController < ApplicationController

  	def new
      @cash_sales = Order.created_between({from_date: Time.now.beginning_of_day, to_date: Time.now.end_of_day}).cash.sum(&:total_amount_less_discount)
      @entry = Accounting::Entry.new
      authorize @entry
      @entry.debit_amounts.build
      @entry.credit_amounts.build
    end

    def create
      @entries = Accounting::Entry.all
      @entry = Accounting::Entry.create(entry_params)
      @entry.recorder = current_user
      if @entry.save
        redirect_to retail_orders_path, notice: 'Entry for sales has been saved successfully.'
      else
        render :new
      end
      authorize @entry
    end

    private
    def entry_params
      params.require(:accounting_entry).permit(:date, :description, :reference_number, debit_amounts_attributes:[:amount, :account_id], credit_amounts_attributes:[:amount, :account_id])
    end
  end
end