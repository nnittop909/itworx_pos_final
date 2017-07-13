class Accounting::IncomeStatementController < ApplicationController
  def index
    @from_date = params[:from_date] ? Date.parse(params[:from_date]) : Date.today.at_beginning_of_month
    @to_date = params[:to_date] ? Date.parse(params[:to_date]) : Date.today
    @revenues = Accounting::Revenue.all
    @expenses = Accounting::Expense.all

    respond_to do |format|
      format.html # index.html.erb
      format.pdf do
        pdf = Accounting::IncomeStatementPdf.new(@revenues, @expenses,  @from_date, @to_date, view_context)
        send_data pdf.render, type: "application/pdf", disposition: 'inline', file_name: "Income Statement.pdf"
      end
    end
  end
end
