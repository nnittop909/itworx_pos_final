class ProductsPdf < Prawn::Document
  TABLE_WIDTHS = [150, 60, 80, 80, 80, 60, 60]
  def initialize(products, view_context)
    super(margin: 20, page_size: [612, 1008], page_layout: :portrait)
    @products = products
    @view_context = view_context
    heading
    display_products_table
  end
  
  def price(number)
    @view_context.number_to_currency(number, :unit => "P ")
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

      header = [["PRODUCT", "UNIT", "RETAIL", "WHOLESALE", "DELIVERIES", "SOLD", "IN STOCK"]]
      table(header, :cell_style => {size: 9, :padding => [2, 4, 2, 4]}, column_widths: TABLE_WIDTHS) do
        cells.borders = []
        row(0).font_style = :bold
        column(1).align = :right
        column(2).align = :right
        column(3).align = :right
        column(4).align = :right
        column(5).align = :right
        column(6).align = :right
      end
      stroke_horizontal_rule

      header = ["", "", "", "", "", "", ""]
      footer = ["", "", "", "", "", "", ""]
      products_data = @products.map { |e| [e.name_and_description, e.unit, price(e.retail_price), price(e.wholesale_price), e.quantity, e.sold, e.in_stock]}
      table_data = [header, *products_data, footer]
      table(table_data, cell_style: { size: 9, font: "Helvetica", inline_format: true, :padding => [2, 4, 2, 4]}, column_widths: TABLE_WIDTHS) do
        cells.borders = [:top]
        row(0).font_style = :bold
        column(1).align = :right
        column(2).align = :right
        column(3).align = :right
        column(4).align = :right
        column(5).align = :right
        column(6).align = :right
      end
    end
  end
end
