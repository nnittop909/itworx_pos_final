module Accounting
  class PayablesToSuppliersPdf < Prawn::Document
    TABLE_WIDTHS = [100, 100, 100, 100,  120]
    def initialize(suppliers, view_context)
      super(margin: 20, page_size: [612, 1008], page_layout: :portrait)
      @suppliers = suppliers
      @view_context = view_context
      heading
      display_products_table

    end
    def price(number)
      @view_context.number_to_currency(number, :unit => "P ")
    end
    def time_ago_in_words_for(time)
      @view_context.time_ago_in_words(time)
    end
    def heading
      text 'ACCOUNTS PAYABLE TO SUPPLIERS', size: 12, align: :center, style: :bold
      move_down 10
      stroke_horizontal_rule
    end
    def display_products_table
      if @suppliers.blank?
        move_down 10
        text "No available data.", align: :center
      else
        move_down 10

        table(table_data, header: true, cell_style: { size: 8, font: "Helvetica"}, column_widths: TABLE_WIDTHS) do
          row(0).font_style = :bold
          row(0).background_color = 'DDDDDD'
          column(1).align = :right
          column(4).align = :right
          row(-1).size = 10
          row(-1).font_style = :bold

        end
      end
    end

    def table_data
      move_down 5
      [["BUSINESS NAME", "OWNER", "ADDRESS", "CONTACT",   "TOTAL AMOUNT"]] +
      @table_data ||= @suppliers.map { |e| [e.business_name, e.owner, e.try(:address), e.mobile_number,  price(e.total_remaining_balance)]} +
      [["TOTAL","","","", "#{price(Supplier.total_remaining_balance)}"]]
    end
  end
end
