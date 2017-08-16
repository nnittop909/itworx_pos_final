module Accounting
  class DueFromCustomersPdf < Prawn::Document
    TABLE_WIDTHS = [140, 220, 90, 122]
    def initialize(members, view_context)
      super(margin: 20, page_size: [612, 1008], page_layout: :portrait)
      @members = Customer.with_credits
      @view_context = view_context
      heading
      display_products_table

    end
    def price(number)
      @view_context.number_to_currency(number, :unit => "P ")
    end
    def time_ago_in_words_for(time)
      @view_context.time_ago_in_words(time)
    end
    def heading
      text "#{Business.last.name}", style: :bold, size: 10, align: :center
      text "#{Business.last.address}", size: 10, align: :center
      move_down 15
      text 'DUE FROM CUSTOMERS', size: 12, align: :center, style: :bold
      move_down 3
      text "As of #{Time.zone.now.strftime("%B %e, %Y")}", size: 10, align: :center
      move_down 5
      stroke_horizontal_rule
    end
    def display_products_table
      if @members.blank?
        move_down 10
        text "No products data.", align: :center
      else
        move_down 10
        header = [["NAME", "ADDRESS", "CONTACT",   "TOTAL AMOUNT"]]
        table(header, :cell_style => {size: 9, :padding => [2, 4, 2, 4]}, column_widths: TABLE_WIDTHS) do
          cells.borders = []
          row(0).font_style = :bold
          column(3).align = :right
        end

        stroke_horizontal_rule
        header = ["", "", "", ""]
        footer = ["", "", "", ""]
        members_data = @members.map { |e| [e.full_name, e.try(:address_details) || "N/A", e.mobile || "N/A",  price(e.total_remaining_balance)]}
        table_data = [header, *members_data, footer]
        table(table_data, cell_style: { size: 9, font: "Helvetica", inline_format: true, :padding => [2, 4, 2, 4]}, column_widths: TABLE_WIDTHS) do
          cells.borders = [:top]
          row(0).font_style = :bold
          column(3).align = :right
        end

        stroke_horizontal_rule
        footer = [["TOTAL","","", "#{price(Customer.total_remaining_balance)}"]]
        table(footer, :cell_style => {size: 9, :padding => [2, 4, 2, 4]}, column_widths: TABLE_WIDTHS) do
          cells.borders = []
          row(0).font_style = :bold
          column(3).align = :right
        end
      end
    end
  end
end
