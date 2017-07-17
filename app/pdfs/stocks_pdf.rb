class StocksPdf < Prawn::Document
  TABLE_WIDTHS = [80, 60, 250, 90, 92]
  def initialize(stocks, from_date, to_date, view_context)
    super(margin: 20, page_size: [612, 1008], page_layout: :portrait)
    @stocks = stocks
    @from_date = from_date
    @to_date = to_date
    @view_context = view_context
    heading
    display_stocks_table

  end
  def price(number)
    @view_context.number_to_currency(number, :unit => "P ")
  end
  def heading
    text "#{Business.last.name}", style: :bold, size: 10, align: :center
    text "#{Business.last.address}", size: 10, align: :center
    move_down 15
    text 'STOCK PURCHASE REPORT', align: :center, style: :bold
    text "#{@from_date.strftime("%B %e, %Y")} - #{@to_date.strftime("%B %e, %Y")}", size: 9, align: :center
    move_down 5
    stroke_horizontal_rule
    move_down 5
    text "TOTAL COST:           #{price(@stocks.total_cost_of_purchase)}", size: 10, style: :bold
    move_down 3



  end
  def display_stocks_table
    if @stocks.blank?
      move_down 10
      text "No stocks data.", align: :center
    else
      move_down 10
      header = [["DATE", "QTY", "PRODUCT", "PRICE", "COST"]]
      table(header, :cell_style => {size: 9, :padding => [1, 4, 1, 4]}, column_widths: TABLE_WIDTHS) do
        cells.borders = []
        row(0).font_style = :bold
      end

      stroke_horizontal_rule

      header = ["", "", "", "", ""]
      footer = ["", "", "", "", ""]
      stocks_data = @stocks.map { |e| [e.date.strftime('%B %e, %Y'), 
      e.converted_total_quantity, e.product.name_and_description, 
      "#{price(e.product.retail_price)} / #{e.product.retail_unit}", 
      "#{price(e.unit_cost)} / #{e.product.retail_unit}"]}
      table_data = [header, *stocks_data, footer]

      table(table_data, cell_style: { size: 9, font: "Helvetica", inline_format: true, :padding => [2, 4, 2, 4]}, column_widths: TABLE_WIDTHS) do
        cells.borders = [:top]
        row(0).font_style = :bold
      end
    end
  end
end
