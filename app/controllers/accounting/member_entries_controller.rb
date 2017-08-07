module Accounting 
  class MemberEntriesController < ApplicationController 
    def new
      @entry = Accounting::Entry.new
      authorize @entry
      @entry.debit_amounts.build
      @entry.credit_amounts.build
    end

    def create
      @entry = Accounting::Entry.create(entry_params)
      @entry.recorder = current_user
      if @entry.save
        redirect_to accounting_entries_path, notice: 'Entry has been saved successfully.'
      else
        render :new
      end
      authorize @entry
    end

    private
    def entry_params
      params.require(:accounting_entry).permit(:commercial_document_id, :commercial_document_type, :date, :description, :reference_number, debit_amounts_attributes:[:amount, :account], credit_amounts_attributes:[:amount, :account])
    end
  end 
end