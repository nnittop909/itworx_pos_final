class CreditsController < ApplicationController
  autocomplete :member, :full_name, full: true
  def index
    if params[:full_name].present?
      @members = Customer.search_by_name(params[:full_name]).page(params[:page]).per(40)
    else
      @has_credits = Customer.with_credits
      @members = Kaminari.paginate_array(@has_credits).page(params[:page]).per(40)
      respond_to do |format|
        format.html
        format.pdf do
          pdf = Accounting::DueFromCustomersPdf.new(@has_credits, view_context)
                send_data pdf.render, type: "application/pdf", disposition: 'inline', file_name: "Credits Report.pdf"
        end
      end
    end
  end
end
