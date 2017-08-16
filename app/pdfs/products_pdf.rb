class ProductsPdf < Prawn::Document
  TABLE_WIDTHS = [150, 40, 70, 80, 70, 70, 92]
  def initialize(products, view_context)
    super(margin: 20, page_size: [612, 1008], page_layout: :portrait)
    @products = Product.all
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
    move_down 2
    table(total_inventory_cost_data, header: true, cell_style: { size: 10, font: "Helvetica", :padding => [1,4,1,4]}, column_widths: [180, 100, 70, 100, 100]) do
      cells.borders = []
      row(0).font_style = :bold
    end
    move_down 2
    stroke_horizontal_rule
  end

  def total_inventory_cost_data
    [["Total Inventory Cost: ", price(Product.total_inventory_cost), "", "", ""]]
  end
  
  def display_products_table
    if @products.blank?
      move_down 10
      text "No products data.", align: :center
    else
      move_down 10

      header = [["PRODUCT", "UNIT", "RETAIL", "WHOLESALE", "DELIVERIES", "IN STOCK", "TOTAL"]]
      table(header, :cell_style => {size: 9, :padding => [2, 4, 2, 4]}, column_widths: TABLE_WIDTHS) do
        cells.borders = []
        row(0).font_style = :bold
        column(1).align = :right
        column(2).align = :right
        column(3).align = :right
        column(4).align = :right
        column(5).align = :right
        column(6).align = :right
        column(7).align = :right
      end
      stroke_horizontal_rule
      Category.order(:name).all.each do |category|
        if category.products.present?
          header = [category.name, "", "", "", "", "", ""]
          footer = ["", "", "", "", "", "SUB-TOTAL:", price(category.products.total_inventory_cost)]
        else
          header = ["", "", "", "", "", "", ""]
          footer = ["", "", "", "", "", "", ""]
        end
        products_data = category.products.available.map { |e| [e.name_and_description, e.unit, price(e.retail_price), price(e.wholesale_price), e.quantity, e.in_stock, price(e.stocks.sum(:total_cost))]}
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
          column(7).align = :right
        end
      end
    end
  end
end
