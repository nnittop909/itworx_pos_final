class CreditsController < ApplicationController
  autocomplete :member, :full_name, full: true
  def index
    if params[:full_name].present?
      @members = Customer.search_by_name(params[:full_name]).page(params[:page]).per(30)
    else
      @has_credit = Customer.with_credits
      @members = Kaminari.paginate_array(@has_credit).page(params[:page]).per(30)
      respond_to do |format|
        format.html
        format.pdf do
          pdf = Accounting::DueFromCustomersPdf.new(@members, view_context)
                send_data pdf.render, type: "application/pdf", disposition: 'inline', file_name: "Credits Report.pdf"
        end
      end
    end
  end
end
