class StocksPdf < Prawn::Document
  TABLE_WIDTHS = [80, 60, 250, 90, 90]
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
    text "#{Business.last.try(:name)}", size: 8
    text "#{Business.last.try(:proprietor)}", size: 8
    text "#{Business.last.try(:tin)}", size: 8
    text "#{Business.last.try(:address)}", size: 8



    text 'STOCK PURCHASE REPORT', align: :center, style: :bold
    text "#{@from_date.strftime("%B %e, %Y")} - #{@to_date.strftime("%B %e, %Y")}", size: 9, align: :center
    move_down 2
    text "TOTAL COST:           #{price(@stocks.total_cost_of_purchase)}", size: 10, style: :bold
    move_down 3
    stroke_horizontal_rule



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
    [["DATE", "QTY", "PRODUCT", "PRICE", "COST"]] +
    @table_data ||= @stocks.map { |e| [e.date.strftime('%B %e, %Y'), 
      e.converted_total_quantity, e.product.name_and_description, 
      "#{price(e.product.retail_price)} / #{e.product.retail_unit}", 
      "#{price(e.unit_cost)} / #{e.product.retail_unit}"]}
  end
end
