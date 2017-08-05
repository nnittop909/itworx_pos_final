module Suppliers
  class PaymentsController < ApplicationController
    def new
      @supplier = Supplier.find(params[:supplier_id])
      @entry = Accounting::Entry.new
      authorize @entry
      @entry.debit_amounts.build
      @entry.credit_amounts.build
    end

    def create
      @supplier = Supplier.find(params[:supplier_id])
      @entry = Accounting::Entry.create(entry_params)
      @entry.commercial_document = @supplier
      @entry.recorder = current_user
      if @entry.save
        redirect_to credit_stocks_supplier_path(@supplier), notice: "Payment saved successfully."
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
