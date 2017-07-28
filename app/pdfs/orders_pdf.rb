class OrdersPdf < Prawn::Document
  TABLE_WIDTHS = [80, 100, 80, 70, 80, 80, 82 ]
  HEADING_WIDTHS = [180,100,70,100, 100]
  def initialize(orders, from_date, to_date, view_context)
    super(margin: 20, page_size: [612, 1008], page_layout: :portrait)
    @orders = orders
    @from_date = from_date
    @to_date = to_date
    @view_context = view_context
    heading
    display_orders_table
  end
  def price(number)
    @view_context.number_to_currency(number, :unit => "P ")
  end
  def heading
    text "#{Business.last.try(:name)}", align: :center, size: 8
    text "#{Business.last.try(:proprietor)}", align: :center, size: 8
    text "#{Business.last.try(:tin)}", align: :center, size: 8
    text "#{Business.last.try(:address)}", align: :center, size: 8
    move_down 5
    text 'SALES REPORT', size: 12, align: :center, style: :bold
    move_down 2
    text "#{@from_date.strftime("%B %e, %Y")} - #{@to_date.strftime("%B %e, %Y")}", size: 9, align: :center
    move_down 5
    stroke_horizontal_rule
    table(heading_sales_data, header: true, cell_style: { size: 10, font: "Helvetica", :padding => [1,4,1,4]}, column_widths: HEADING_WIDTHS) do
      cells.borders = []
    end
    table(sales_total_data, header: true, cell_style: { size: 10, font: "Helvetica", text_color: "00A244", :padding => [1,4,1,4]}, column_widths: HEADING_WIDTHS) do
      cells.borders = []
    end
    move_down 3
    table(heading_discounts_data, header: true, cell_style: { size: 10, font: "Helvetica", text_color: "C2332D", :padding => [1,4,1,4]}, column_widths: HEADING_WIDTHS) do
      cells.borders = []
    end
    move_down 3
    table(heading_income_data, header: true, cell_style: { size: 10, font: "Helvetica", :padding => [1,4,1,4]}, column_widths: HEADING_WIDTHS) do
      cells.borders = []
    end
    stroke_horizontal_rule
    table(income_total_data, header: true, cell_style: { size: 10, font: "Helvetica", :padding => [1,4,1,4]}, column_widths: HEADING_WIDTHS) do
      cells.borders = []
      row(0).font_style = :bold
    end
    move_down 10
  end

  def heading_sales_data
    [["SALES (CASH): ", "#{price(@orders.cash.sum(&:total_amount_less_discount))}", "", "", ""]] +
    [["SALES (CREDIT): ", "#{price(@orders.credit.sum(&:total_amount_less_discount))}", "", "", ""]]
  end
  def sales_total_data
    [["TOTAL SALES: ", "#{price(@orders.sum(&:total_amount_less_discount))}", "", "", ""]]
  end
  def heading_discounts_data
    [["TOTAL DISCOUNT: ", "#{price(@orders.map{|a| a.total_discount}.sum)}", "", "", ""]] +
    [["TOTAL COST OF GOODS SOLD: ", "#{price(@orders.map{|a| a.cost_of_goods_sold}.sum)}", "", "", ""]]
  end
  def heading_income_data
    [["INCOME (CASH): ", "#{price(@orders.select{|a| a.cash?}.map{|a| a.income}.sum)}", "", "", ""]] +
    [["INCOME (CREDIT): ", "#{price(@orders.select{|a| a.credit?}.map{|a| a.income}.sum)}", "", "", ""]]
  end
  def income_total_data
    [["INCOME (TOTAL): ", " #{price(@orders.map{|a| a.income}.sum)}", "", "", ""]]
  end

  def display_orders_table
    if @orders.blank?
      move_down 10
      text "No orders data.", align: :center
    else
      move_down 10
      text "SALES", style: :bold
      move_down 4
      header = [["DATE", "CUSTOMER", "SUB TOTAL", "DISCOUNT", "TOTAL SALES", "COST OF GOODS SOLD", "INCOME"]]
      table(header, :cell_style => {size: 9, :padding => [2, 4, 2, 4]}, column_widths: TABLE_WIDTHS) do
        cells.borders = []
        row(0).font_style = :bold
        column(2).align = :right
        column(3).align = :right
        column(4).align = :right
        column(5).align = :center
        column(6).align = :right
      end
      stroke_horizontal_rule
      header = ["", "", "", "", "", "", ""]
      footer = ["", "", "", "", "", "", ""]
      orders_data = @orders.map { |e| [e.date.strftime("%B %e, %Y \n%I:%M %p"), e.customer_name, price(e.total_amount_without_discount), price(e.total_discount), price(e.total_amount_less_discount), price(e.cost_of_goods_sold), price(e.income)]}
      table_data = [header, *orders_data, footer]
      table(table_data, cell_style: { size: 9, font: "Helvetica", inline_format: true, :padding => [2, 4, 2, 4]}, column_widths: TABLE_WIDTHS) do
        cells.borders = [:top]
        row(0).font_style = :bold
        column(2).align = :right
        column(3).align = :right
        column(4).align = :right
        column(5).align = :right
        column(6).align = :right
      end

      stroke_horizontal_rule
      footer = [["", "", "#{price(@orders.created_between(from_date: @from_date.yesterday.end_of_day, to_date: @to_date.end_of_day).total_amount_without_discount)}", 
        "#{price(@orders.created_between(from_date: @from_date, to_date: @to_date).total_discount)}", 
        "#{price(@orders.created_between(from_date: @from_date, to_date: @to_date).total_amount_less_discount)}", 
        "#{price(@orders.created_between(from_date: @from_date, to_date: @to_date).cost_of_goods_sold)}", 
        "#{price(@orders.created_between(from_date: @from_date, to_date: @to_date).income)}"]]
      table(footer, :cell_style => {size: 9, :padding => [2, 4, 2, 4]}, column_widths: TABLE_WIDTHS) do
        cells.borders = []
        row(0).font_style = :bold
        column(2).align = :right
        column(3).align = :right
        column(4).align = :right
        column(5).align = :right
        column(6).align = :right
      end
    end
  end

  def table_data
    move_down 5
    [["DATE", "CUSTOMER", "SUB TOTAL", "DISCOUNT", "TOTAL SALES", "COST OF GOODS SOLD", "INCOME"]] +
    @table_data ||= @orders.map { |e| [e.date.strftime("%B %e, %Y %I:%M %p"), e.customer_name, price(e.total_amount_without_discount), price(e.total_discount), price(e.total_amount_less_discount), price(e.cost_of_goods_sold), price(e.income)]} +
    [["", "", "#{price(@orders.created_between(from_date: @from_date.yesterday.end_of_day, to_date: @to_date.end_of_day).total_amount_without_discount)}", "#{price(@orders.created_between(from_date: @from_date, to_date: @to_date).total_discount)}", "#{price(@orders.created_between(from_date: @from_date, to_date: @to_date).total_amount_less_discount)}", "#{price(@orders.created_between(from_date: @from_date, to_date: @to_date).cost_of_goods_sold)}", "#{price(@orders.created_between(from_date: @from_date, to_date: @to_date).income)}"]]
  end
end
