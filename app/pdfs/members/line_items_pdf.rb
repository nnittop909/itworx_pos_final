module Members
  class LineItemsPdf < Prawn::Document
    TABLE_WIDTHS = [90, 50, 170, 80, 70, 70]
    HEADING_WIDTHS = [100,100,100,100, 100]
    def initialize(member, line_items, from_date, to_date, view_context)
      super(margin: 40, page_size: [612, 1008], page_layout: :portrait)
      @member = member
      @line_items = line_items
      @from_date = from_date
      @to_date = to_date
      @view_context = view_context
      logo
      heading
      display_cash_line_items_table
      display_credit_line_items_table
      footer_for_itworx


    end
    def price(number)
      @view_context.number_to_currency(number, :unit => "P ")
    end
    def logo
      y_position = cursor
      # image "#{Business.last.logo.path(:medium)}", height: 50, width: 50, at: [1, y_position]
      bounding_box [60, 930], width: 200 do
        text "<b>#{Business.last.try(:name)}</b>", size: 8, inline_format: true
        text "Proprietor: #{Business.last.try(:proprietor)}", size: 8, inline_format: true
        text "TIN: #{Business.last.try(:tin)}", size: 8, inline_format: true
        text "Contact #: #{Business.last.try(:mobile_number)}", size: 8, inline_format: true
        text "Email: #{Business.last.try(:email)}", size: 8, inline_format: true
      end
    end
    def heading
     move_down 10
      text "CUSTOMER TRANSACTION REPORT", align: :center, style: :bold
      move_down 1
      text "#{@from_date.strftime('%B')} - #{@to_date.strftime('%B')}, #{@to_date.strftime('%Y')}", align: :center, size: 10
      stroke_horizontal_rule
      move_down 10
      text "SUMMARY", style: :bold, size: 10
      table(heading_data, header: true, cell_style: { size: 10, font: "Helvetica", :padding => [5,5,0,0]}, column_widths: HEADING_WIDTHS) do
        cells.borders = []

      end
  move_down 10
      stroke_horizontal_rule
    end
    def heading_data
      [["#{@member.full_name}", "", "", "Cash Transaction", "#{price(@member.total_cash_transactions)}"]] +
      [["#{@member.address}", "", "", "Credit Transaction", "#{price(@member.total_credit_transactions)}" ]] +
      [["#{@member.mobile}", "", "", "Total Payment", "#{price(@member.total_payment)}" ]] +
      [["", "", "", "Remaining Balance", "#{price(@member.total_remaining_balance)}" ]] +
        [["", "", "", "Total Discount", "#{price(@member.total_discount)}" ]] +
      [["", "", "", "" ]] +
      [["", "", "", "" ]]

    end

    def display_cash_line_items_table
      if @line_items.blank?
        move_down 10
        text "No orders data.", align: :center
      else
        move_down 10
        text "CASH TRANSACTIONS", size: 10, style: :bold
        table(cash_data, header: true, cell_style: { size: 8, font: "Helvetica"}, column_widths: TABLE_WIDTHS) do
          row(0).font_style = :bold
        # /  row(0).background_color = 'DDDDDD'
          column(4).align = :right
          column(5).align = :right

        end
      end
    end

    def cash_data
      move_down 5
      [["DATE", "QTY", "PRODUCT",  "SERIAL", "PRICE", "AMOUNT"]] +
      @cash_data ||= @member.line_items.cash.map { |e| [e.created_at.strftime("%B %e, %Y"), e.converted_quantity, e.stock.product.name_and_description, e.stock.try(:serial_number), price(e.converted_price), price(e.total_price)]}
    end

    def display_credit_line_items_table
      if @member.line_items.credit.blank?
        move_down 20
        text "CREDIT TRANSACTIONS", size: 10, style: :bold
        text "No credit data."
      else
        move_down 10
        text "CREDIT TRANSACTIONS", size: 10, style: :bold
        table(credit_data, header: true, cell_style: { size: 8, font: "Helvetica"}, column_widths: TABLE_WIDTHS) do
          row(0).font_style = :bold
        # /  row(0).background_color = 'DDDDDD'
          column(4).align = :right
          column(5).align = :right

        end
      end
    end

    def credit_data
      move_down 5
      [["DATE", "QTY", "PRODUCT",  "SERIAL", "PRICE", "AMOUNT"]] +
      @credit_data ||= @line_items.map { |e| 
        if e.class.name == "LineItem"
          [e.created_at.strftime("%B %e, %Y - %I:%M %p"), e.converted_quantity, e.stock.try(:name), e.stock.try(:serial_number), price(e.converted_price), price(e.total_price)]
        else
          [e.created_at.strftime("%B %e, %Y - %I:%M %p"), "#{e.quantity} #{e.unit}", e.name, "", price(e.unit_cost), price(e.total_cost)]
        end
      }
    end
    def footer_for_itworx
      bounding_box([10, 5], :width => 500, :height => 110) do
        stroke_horizontal_rule
        move_down 5
        text 'This establsihment is  supported by <b>ITWORX POINT-OF- SALE SYSTEM.</b>', size: 8, inline_format: true, align: :center
        text 'Developed by <b> ITWORX TECHNOLOGY SERVICES</b> Email us at <b> vc.halip@gmail.com </b> Contact # <b> 0927 4173 271</b>', size: 8, inline_format: true, align: :center
      end
    end
  end
end
