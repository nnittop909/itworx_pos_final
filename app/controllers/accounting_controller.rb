class AccountingController < ApplicationController

  autocomplete :account, :name, full: true, class_name: 'Accounting::Account'

  def index
    if params[:name].present?
      @active_accounts = Accounting::Account.active.all.order(:code).page(params[:page]).per(30).search_by_name(params[:name])
      @inactive_accounts = Accounting::Account.inactive.all.order(:code).page(params[:page]).per(30).search_by_name(params[:name])
    else
      @active_accounts = Accounting::Account.active.all.order(:code).page(params[:page]).per(30)
      @inactive_accounts = Accounting::Account.inactive.all.order(:code).page(params[:page]).per(30)

      first_entry = Accounting::Entry.order('date ASC').first
      @from_date = first_entry ? first_entry.date: Date.today
      @to_date = params[:date] ? DateTime.parse(params[:date]) : Date.today
      @assets = Accounting::Asset.active.all.order(:code)
      @liabilities = Accounting::Liability.active.all.order(:code)
      @equity = Accounting::Equity.active.all.order(:code)
      @revenues = Accounting::Revenue.all.order(:code)
      @expenses = Accounting::Expense.all.order(:code)
      @entries = Accounting::Entry.all.order(:date)
    end
  end
end
