class ProductsPdf < Prawn::Document
  TABLE_WIDTHS = [150, 60, 80, 80, 80]
  def initialize(products, view_context)
    super(margin: 40, page_size: [612, 1008], page_layout: :portrait)
    @products = products
    @view_context = view_context
    heading
    display_products_table
  end
  
  def price(number)
    @view_context.number_to_currency(number, :unit => "")
  end

  def heading
    text "#{Business.last.name}", style: :bold, size: 10, align: :center
    text "#{Business.last.address}", size: 10, align: :center
    move_down 15
    text 'CURRENT INVENTORY REPORT', size: 12, align: :center
    move_down 5
    stroke_horizontal_rule
  end
  
  def display_products_table
    if @products.blank?
      move_down 10
      text "No products data.", align: :center
    else
      move_down 10

      table(table_data, header: true, cell_style: { size: 10, font: "Helvetica"}, column_widths: TABLE_WIDTHS) do
        row(0).font_style = :bold
        row(0).background_color = 'DDDDDD'
        column(1).align = :right
        column(2).align = :right
        column(3).align = :right
        column(4).align = :right
        column(5).align = :right


      end
    end
  end

  def table_data
    move_down 5
    [["PRODUCT", "RETAIL", "WHOLESALE", "DELIVERIES", "SOLD", "IN STOCK"]] +
    @table_data ||= @products.map { |e| [e.name_and_description,  price(e.price), price(e.converted_wholesale_price), price(e.converted_total_quantity), price(e.converted_sold_quantity), price(e.converted_in_stock_quantity)]}
  end
end
