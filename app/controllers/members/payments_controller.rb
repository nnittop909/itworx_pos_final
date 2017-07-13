module Members
  class PaymentsController < ApplicationController
    def new
      @member = User.customer.find(params[:member_id])
      @entry = Accounting::Entry.new
      authorize @entry
      @entry.debit_amounts.build
      @entry.credit_amounts.build
    end

    def create
      @member = User.customer.find(params[:member_id])
      @entry = Accounting::Entry.create(entry_params)
      @entry.commercial_document = @member
      @entry.recorder = current_user
      if @entry.save
        redirect_to account_details_member_path(@member), notice: "Payment saved successfully."
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
      params.require(:accounting_entry).permit(:date, :description, :reference_number, debit_amounts_attributes:[:amount, :account_id, :id], credit_amounts_attributes:[:amount, :account_id, :id])
    end
  end
end
