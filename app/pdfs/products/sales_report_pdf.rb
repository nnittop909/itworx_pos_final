module Products
  class SalesReportPdf < Prawn::Document
    TABLE_WIDTHS = [80, 60, 130, 40, 90, 90, 82]
    HEADING_WIDTHS = [180,90,80,100, 100]
    def initialize(product, line_items, from_date, to_date, view_context)
      super(margin: 20, page_size: [612, 1008], page_layout: :portrait)
      @product = product
      @line_items = line_items
      @from_date = from_date
      @to_date = to_date
      @view_context = view_context
      logo
      heading
      display_cash_line_items_table
    end
    def price(number)
      @view_context.number_to_currency(number, :unit => "P ")
    end
    def logo
      text "#{Business.last.try(:name)}", size: 11, align: :center, style: :bold
      text "#{Business.last.address}", size: 10, align: :center
    end
    def heading
      move_down 10
      text "PRODUCT SALES REPORT", size: 11, align: :center, style: :bold
      text "(#{@product.name.upcase})", size: 11, align: :center, style: :bold
      move_down 2
      if @from_date.strftime("%B %e, %Y") == @to_date.strftime("%B %e, %Y")
        text "#{@from_date.strftime("%B %e, %Y")}", size: 9, align: :center
      else
        text "#{@from_date.strftime("%B %e, %Y")} - #{@to_date.strftime("%B %e, %Y")}", size: 9, align: :center
      end
      stroke_horizontal_rule
      move_down 5

      table(heading_sales_data, header: true, cell_style: { size: 10, font: "Helvetica", :padding => [1,4,1,4]}, column_widths: HEADING_WIDTHS) do
        cells.borders = []
        column(1).align = :right
      end
      table(sales_total_data, header: true, cell_style: { size: 10, font: "Helvetica", text_color: "00A244", :padding => [1,4,1,4]}, column_widths: HEADING_WIDTHS) do
        cells.borders = []
        column(1).align = :right
      end
      move_down 3
      table(heading_discounts_data, header: true, cell_style: { size: 10, font: "Helvetica", text_color: "C2332D", :padding => [1,4,1,4]}, column_widths: HEADING_WIDTHS) do
        cells.borders = []
        column(1).align = :right
      end
      move_down 3
      table(heading_income_data, header: true, cell_style: { size: 10, font: "Helvetica", :padding => [1,4,1,4]}, column_widths: HEADING_WIDTHS) do
        cells.borders = []
        column(1).align = :right
      end
      move_down 3
      stroke_horizontal_rule
      table(income_total_data, header: true, cell_style: { size: 10, font: "Helvetica", :padding => [1,4,1,4]}, column_widths: HEADING_WIDTHS) do
        cells.borders = []
        column(1).align = :right
        row(0).font_style = :bold
      end
      move_down 10
    end
    def heading_sales_data
      [["SALES (CASH): ", "#{price(@line_items.select{|a| a.order.cash?}.pluck(:total_cost).sum)}", "", "SOLD:", "#{@line_items.map{|a| a.quantity}.sum}"]] +
      [["SALES (CREDIT): ", "#{price(@line_items.select{|a| a.order.credit?}.pluck(:total_cost).sum)}", "", "IN STOCK:", "#{@product.in_stock}"]]
    end
    def sales_total_data
      [["TOTAL SALES: ", "#{price(@line_items.pluck(:total_cost).sum)}", "", "", "", ""]]
    end
    def heading_discounts_data
      [["TOTAL COST OF GOODS SOLD: ", "#{price(@line_items.map{|a| a.cost_of_goods_sold}.sum)}", "", "", ""]]
    end
    def heading_income_data
      [["INCOME (CASH): ", "#{price(@line_items.select{|a| a.order.cash?}.map{|a| a.income}.sum)}", "", "", ""]] +
      [["INCOME (CREDIT): ", "#{price(@line_items.select{|a| a.order.credit?}.map{|a| a.income}.sum)}", "", "", ""]]
    end
    def income_total_data
      [["INCOME (TOTAL): ", "#{price(@line_items.map{|a| a.income}.sum)}", "", "", ""]]
    end

    def display_cash_line_items_table
      if @line_items.blank?
        move_down 15
        text "No sales data.", align: :center
      else
        move_down 10
        text "SALES TRANSACTIONS", size: 10, style: :bold
        move_down 4
        header = [["DATE", "QTY", "CUSTOMER",  "TYPE", "COST", "TOTAL COST", "INCOME"]]
        table(header, :cell_style => {size: 9, :padding => [2, 4, 2, 4]}, column_widths: TABLE_WIDTHS) do
          cells.borders = []
          row(0).font_style = :bold
          column(3).align = :center
          column(4).align = :right
          column(5).align = :right
          column(6).align = :right
        end
        stroke_horizontal_rule
        header = ["", "", "", "", "", "", ""]
        footer = ["", "", "", "", "", "", ""]
        orders_data = @line_items.to_a.sort_by(&:order_date).reverse.map { |e| [e.order_date.strftime("%B %e, %Y"), "#{e.quantity} #{e.stock.product.unit}", e.order.try(:customer_name), e.type, price(e.unit_price), price(e.total_price), price(e.income)]}
        table_data = [header, *orders_data, footer]
        table(table_data, cell_style: { size: 9, font: "Helvetica", inline_format: true, :padding => [2, 4, 2, 4]}, column_widths: TABLE_WIDTHS) do
          cells.borders = [:top]
          row(0).font_style = :bold
          column(3).align = :center
          column(4).align = :right
          column(5).align = :right
          column(6).align = :right
        end
      end
    end
  end
end
