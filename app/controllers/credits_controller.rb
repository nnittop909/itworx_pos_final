class CreditsController < ApplicationController
  autocomplete :member, :full_name, full: true
  def index
    if params[:full_name].present?
      @members = User.customer.search_by_name(params[:full_name]).page(params[:page]).per(30)
    else
      @members = User.customer.all
      respond_to do |format|
        format.html
        format.pdf do
          pdf = Accounting::DueFromCustomersPdf.new(@members, view_context)
                send_data pdf.render, type: "application/pdf", disposition: 'inline', file_name: "Products Report.pdf"
        end
      end
    end
  end
end
