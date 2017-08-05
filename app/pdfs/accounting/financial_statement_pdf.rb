module Accounting
  class FinancialStatementPdf < Prawn::Document
    TABLE_WIDTHS = [170, 80, 80, 80, 80, 80]
    def initialize(accounts, view_context)
      super(margin: 20, page_size: [612, 1008], page_layout: :portrait)
      @accounts = accounts
      @view_context = view_context
      heading
      display_products_table

    end
    def price(number)
      @view_context.number_to_currency(number, :unit => "P ")
    end
    def heading
      text 'Reports', size: 12, align: :center
    end
    def display_products_table
      if @accounts.blank?
        move_down 10
        text "No products data.", align: :center
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
      [["NAME", "PRICE", "WHOLESALE PRICE", "IN STOCK", "UNIT", "STOCK ALERT"]] +
      @table_data ||= @products.map { |e| [e.name, price(e.price), price(e.wholesale_price), e.quantity, e.unit,e.stock_status]}
    end
  end
end
