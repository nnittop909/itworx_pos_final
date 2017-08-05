class PayablesController < ApplicationController 
	def index
    if params[:name].present?
      @suppliers = Supplier.search_by_name(params[:name])
    else
      @suppliers = Supplier.by_total_credit
      respond_to do |format|
        format.html
        format.pdf do
          pdf = Accounting::PayablesToSuppliersPdf.new(@suppliers, view_context)
                send_data pdf.render, type: "application/pdf", disposition: 'inline', file_name: "Products Report.pdf"
        end
      end
    end
  end
end

