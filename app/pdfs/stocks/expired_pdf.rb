module Stocks
  class ExpiredPdf < Prawn::Document
    TABLE_WIDTHS = [200, 70, 150, 152 ]
    def initialize(stocks, view_context)
      super(margin: 20, page_size: [612, 1008], page_layout: :portrait)
      @stocks = stocks
      @view_context = view_context
      heading
      display_products_table

    end
    def price(number)
      @view_context.number_to_currency(number, :unit => "P ")
    end
    def heading
      text "#{Business.last.name}", style: :bold, size: 11, align: :center
      text "#{Business.last.address}", size: 10, align: :center
      move_down 10
      text 'Expired Stocks Report', size: 11, align: :center, style: :bold
      move_down 3
      text "As of #{Time.zone.now.strftime("%B %e, %Y")}", size: 10, align: :center
      move_down 10
      stroke_horizontal_rule
      move_down 5
    end
    def display_products_table
      if @products.blank?
        move_down 10
        text "No products data.", align: :center
      else
        move_down 10
        header = [["STOCK", "UNIT", "IN STOCK", "SOLD"]]
        table(header, :cell_style => {size: 9, :padding => [2, 4, 2, 4]}, column_widths: TABLE_WIDTHS) do
          cells.borders = []
          row(0).font_style = :bold
        end

        stroke_horizontal_rule
        Category.order(:name).all.each do |category|
          if category.products.present?
            header = [category.name, "", "", ""]
          else
            header = ["", "", "", ""]
          end
          footer = ["", "", "", ""]
          products_data = category.products.map { |e| [e.name_and_description, e.unit, e.quantity, e.sold]}
          table_data = [header, *products_data, footer]
          table(table_data, cell_style: { size: 9, font: "Helvetica", inline_format: true, :padding => [2, 4, 2, 4]}, column_widths: TABLE_WIDTHS) do
            cells.borders = [:top]
            row(0).font_style = :bold
          end
        end
      end
    end
  end
end
