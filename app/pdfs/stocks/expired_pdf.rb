module Stocks
  class ExpiredPdf < Prawn::Document
    TABLE_WIDTHS = [170, 80, 80, 80, 120 ]
    def initialize(stocks, view_context)
      super(margin: 40, page_size: [612, 1008], page_layout: :portrait)
      @stocks = stocks
      @view_context = view_context
      heading
      display_stocks_table

    end
    def price(number)
      @view_context.number_to_currency(number, :unit => "P ")
    end
    def heading
      text 'Expired Stocks Report', size: 12, align: :center, style: :bold
      move_down 10
      stroke_horizontal_rule
      move_down 5
    end
    def display_stocks_table
      if @stocks.blank?
        move_down 10
        text "No stocks data.", align: :center
      else
        move_down 10

        table(table_data, header: true, cell_style: { size: 8, font: "Helvetica"}, column_widths: TABLE_WIDTHS) do
          row(0).font_style = :bold
          row(0).background_color = 'DDDDDD'
        end
      end
    end

    def table_data
      move_down 5
      [["STOCK", "UNIT", "IN STOCK", "SOLD", "DATE EXPIRED"]] +
      @table_data ||= @stocks.map { |e| [e.product.name_and_description, price(e.product.try(:unit)), e.converted_total_quantity, e.sold, e.expiry_date.strftime("%B %e, %Y")]}
    end
  end
end
