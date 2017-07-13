module Accounting
  class DueFromCustomersPdf < Prawn::Document
    TABLE_WIDTHS = [150, 150, 110,  120]
    def initialize(members, view_context)
      super(margin: 40, page_size: [612, 1008], page_layout: :portrait)
      @members = members
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
      text 'DUE FROM CUSTOMERS', size: 12, align: :center, style: :bold
      move_down 10
      stroke_horizontal_rule
    end
    def display_products_table
      if @members.blank?
        move_down 10
        text "No products data.", align: :center
      else
        move_down 10

        table(table_data, header: true, cell_style: { size: 8, font: "Helvetica"}, column_widths: TABLE_WIDTHS) do
          row(0).font_style = :bold
          row(0).background_color = 'DDDDDD'
          column(3).align = :right
          row(-1).size = 10
          row(-1).font_style = :bold

        end
      end
    end

    def table_data
      move_down 5
      [["NAME", "ADDRESS", "CONTACT",   "TOTAL AMOUNT"]] +
      @table_data ||= @members.map { |e| [e.full_name, e.try(:address_details), e.mobile,  price(e.total_remaining_balance)]} +
      [["TOTAL","","", "#{price(Member.total_remaining_balance)}"]]
    end
  end
end
