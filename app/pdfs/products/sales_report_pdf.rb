module Products
  class SalesReportPdf < Prawn::Document
    TABLE_WIDTHS = [80, 50, 110, 80, 60, 80, 70]
    HEADING_WIDTHS = [100,100,100,100, 100]
    def initialize(product, line_items, from_date, to_date, view_context)
      super(margin: 40, page_size: [612, 1008], page_layout: :portrait)
      @product = product
      @line_items = line_items
      @from_date = from_date
      @to_date = to_date
      @view_context = view_context
      logo
      heading
      sales_details
      display_cash_line_items_table



    end
    def price(number)
      @view_context.number_to_currency(number, :unit => "P ")
    end
    def logo
      y_position = cursor
      # image "#{Business.last.logo.path(:medium)}", height: 50, width: 50, at: [1, y_position]
      bounding_box [60, 930], width: 200 do
        text "<b>#{Business.last.try(:name)}</b>", size: 10, inline_format: true
        text "Proprietor: #{Business.last.try(:proprietor)}", size: 10, inline_format: true
        text "TIN: #{Business.last.try(:tin)}", size: 10, inline_format: true
        text "Contact #: #{Business.last.try(:mobile_number)}", size: 10, inline_format: true
        text "Email: #{Business.last.try(:email)}", size: 10, inline_format: true
      end
    end
    def heading
     move_down 10
      text "PRODUCT SALES REPORT", align: :center, style: :bold
      text "(#{@product.name.upcase})", align: :center, style: :bold

      stroke_horizontal_rule
      move_down 10
     
      end

    def sales_details
       text "SALES SUMMARY", size: 10, style: :bold
        move_down 5
       text " FROM DATE:                                                   #{@from_date.strftime("%B %e, %Y")}", size: 10
       move_down 3
      text " TO DATE:                                                        #{@to_date.strftime("%B %e, %Y")}", size: 10
       move_down 10
      text "SOLD:                                                              #{@line_items.map{|a| a.quantity}.sum}", size: 10
      move_down 3
      text "IN STOCK:                                                       #{@product.in_stock}", size: 10
      move_down 10
      text "SALES (CASH):                                               #{price(@line_items.select{|a| a.order.cash?}.pluck(:total_cost).sum)}", size: 10
      move_down 3
      text "SALES (CREDIT):                                           #{price(@line_items.select{|a| a.order.credit?}.pluck(:total_cost).sum)}", size: 10
      move_down 3
      text "TOTAL SALES:                                                #{price(@line_items.pluck(:total_cost).sum)}", size: 10, color: "00A244"
      move_down 3
      text "TOTAL COST OF GOODS SOLD                   #{price(@line_items.map{|a| a.cost_of_goods_sold}.sum)}", size: 10, color: "C2332D"
      move_down 10
      text "INCOME (CASH):                                            #{price(@line_items.select{|a| a.order.cash?}.map{|a| a.income}.sum)}", size: 10
       move_down 3
      text "INCOME (CREDIT):                                        #{price(@line_items.select{|a| a.order.credit?}.map{|a| a.income}.sum)}", size: 10
       move_down 3
       stroke_horizontal_rule
       move_down 5
      text "INCOME (TOTAL):                              #{price(@line_items.map{|a| a.income}.sum)}", size: 12, style: :bold


    end

    def display_cash_line_items_table
      if @line_items.blank?
        move_down 15
        text "No sales data.", align: :center
      else
        move_down 10
        text "SALES TRANSACTIONS", size: 10, style: :bold
        table(cash_data, header: true, cell_style: { size: 8, font: "Helvetica"}, column_widths: TABLE_WIDTHS) do
          row(0).font_style = :bold
        # /  row(0).background_color = 'DDDDDD'
          column(4).align = :right
          column(5).align = :right

        end
      end
    end

    def cash_data
      move_down 5
      [["DATE", "QTY", "CUSTOMER",  "TYPE", "COST", "TOTAL COST", "INCOME"]] +
      @cash_data ||= @line_items.to_a.sort_by(&:order_date).reverse.map { |e| [e.order_date.strftime("%B %e, %Y"), e.quantity, e.order.try(:customer_name), e.type, price(e.unit_cost), price(e.total_cost), price(e.income)]}
    end
  end
end
