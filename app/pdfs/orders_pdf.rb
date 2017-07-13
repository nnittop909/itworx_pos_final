class OrdersPdf < Prawn::Document
  TABLE_WIDTHS = [80, 100, 80, 70, 80, 80, 80 ]
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
    text "#{Business.last.try(:name)}", size: 8
    text "#{Business.last.try(:proprietor)}", size: 8
    text "#{Business.last.try(:tin)}", size: 8
    text "#{Business.last.try(:address)}", size: 8



    text 'SALES REPORT', size: 12, align: :center, style: :bold
    move_down 2
    text "#{@from_date.strftime("%B %e, %Y")} - #{@to_date.strftime("%B %e, %Y")}", size: 9, align: :center
    move_down 3
    stroke_horizontal_rule
    move_down 10
      text "SALES (CASH):                                             #{price(@orders.cash.sum(&:total_amount_less_discount))}", size: 10
      move_down 3
      text "SALES (CREDIT):                                          #{price(@orders.credit.sum(&:total_amount_less_discount))}", size: 10
      move_down 3
      text "TOTAL SALES:                                               #{price(@orders.sum(&:total_amount_less_discount))}", size: 10, color: "00A244"
      move_down 10
      text "TOTAL DISCOUNT:                                        #{price(@orders.map{|a| a.total_discount}.sum)}", size: 10, color: "C2332D"
      move_down 3
      text "TOTAL COST OF GOODS SOLD                  #{price(@orders.map{|a| a.cost_of_goods_sold}.sum)}", size: 10, color: "C2332D"
      move_down 10
      text "INCOME (CASH):                                          #{price(@orders.select{|a| a.cash?}.map{|a| a.income}.sum)}", size: 10
       move_down 3
      text "INCOME (CREDIT):                                       #{price(@orders.select{|a| a.credit?}.map{|a| a.income}.sum)}", size: 10
       move_down 3
       stroke_horizontal_rule
       move_down 5
      text "INCOME (TOTAL):                            #{price(@orders.map{|a| a.income}.sum)}", size: 12, style: :bold



   move_down 20


  end
  def display_orders_table
    if @orders.blank?
      move_down 10
      text "No orders data.", align: :center
    else
      move_down 10
      text "SALES", style: :bold
      table(table_data, header: true, cell_style: { size: 8, font: "Helvetica"}, column_widths: TABLE_WIDTHS) do
        row(0).font_style = :bold
      # /  row(0).background_color = 'DDDDDD'
        column(2).align = :right
        column(3).align = :right
        column(4).align = :right
        column(5).align = :right
        column(6).align = :right

        row(-1).font_style = :bold
        row(-1).size = 11
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
