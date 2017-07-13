class Accounting::BalanceSheetController < ApplicationController
  def index
    first_entry = Accounting::Entry.order('date ASC').first
    @from_date = first_entry ? first_entry.date: Date.today
    @to_date = params[:date] ? Date.parse(params[:date]) : Date.today
    @assets = Accounting::Asset.all
    @liabilities = Accounting::Liability.all
    @equity = Accounting::Equity.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end
end
