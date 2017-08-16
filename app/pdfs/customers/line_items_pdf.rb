module Customers
  class LineItemsPdf < Prawn::Document
    TABLE_WIDTHS = [90, 50, 170, 80, 70, 72]
    HEADING_WIDTHS = [200,100,100,100]
    def initialize(member, orders, from_date, to_date, view_context)
      super(margin: 40, page_size: [612, 1008], page_layout: :portrait)
      @member = member
      @orders = orders
      @from_date = from_date
      @to_date = to_date
      @view_context = view_context
      heading
      display_cash_line_items_table
      display_credit_line_items_table
      footer_for_itworx


    end
    def price(number)
      @view_context.number_to_currency(number, :unit => "P ")
    end
    def heading
      text "#{Business.last.try(:name)}", size: 8, align: :center, style: :bold
      text "Proprietor: #{Business.last.try(:proprietor)}", size: 8, align: :center
      text "TIN: #{Business.last.try(:tin)}", size: 8, align: :center
      text "#{Business.last.try(:mobile_number)}  #{Business.last.try(:email)}", size: 8, align: :center
      move_down 10
      text "CUSTOMER TRANSACTION REPORT", align: :center, style: :bold
      move_down 1
      text "#{@from_date.strftime('%B')} - #{@to_date.strftime('%B')}, #{@to_date.strftime('%Y')}", align: :center, size: 10
      stroke_horizontal_rule
      move_down 5
      text "SUMMARY", style: :bold, size: 10
      table(heading_data, header: true, cell_style: { size: 10, font: "Helvetica", :padding => [3,3,0,0]}, column_widths: HEADING_WIDTHS) do
        cells.borders = []
      end
      move_down 10
      stroke_horizontal_rule
    end
    def heading_data
      [["#{@member.full_name}", "", "Cash Transaction:", "#{price(@member.total_cash_transactions)}"]] +
      [["#{@member.address_details || "Address: N/A"}", "", "Credit Transaction:", "#{price(@member.total_credit_transactions)}" ]] +
      [["#{@member.mobile}", "", "Total Payment:", "#{price(@member.total_payment)}" ]] +
      [["", "", "Remaining Balance:", "#{price(@member.total_remaining_balance)}" ]] +
      [["", "", "Total Discount:", "#{price(@member.total_discount)}" ]] +
      [["", "", "", "" ]]

    end

    def display_cash_line_items_table
      move_down 10
      text "CASH TRANSACTIONS", size: 10, style: :bold
      move_down 5
      if @orders.cash.blank?
        text "No orders data.", align: :center
      else
        header = [["DATE", "QTY", "PRODUCT", "SERIAL", "PRICE", "AMOUNT"]]
        table(header, :cell_style => {size: 9, :padding => [2, 4, 2, 4]}, column_widths: TABLE_WIDTHS) do
          cells.borders = []
          row(0).font_style = :bold
          column(1).align = :right
          column(2).align = :center
          column(3).align = :center
          column(4).align = :right
          column(5).align = :right
        end
        stroke_horizontal_rule
        move_down 5
        @orders.cash.each do |order|
          header = ["", "", "", "", "", ""]
          footer = ["", "", "", "", "", ""]
          line_items_data = order.line_items.map { |e| [
            e.created_at.strftime("%B %e, %Y"), 
            "#{e.quantity.to_i} #{e.stock.product.unit}", 
            e.stock.product.name_and_description, 
            e.stock.try(:serial_number), 
            price(e.unit_price), 
            price(e.total_price) 
          ]}

          table_data = [header, *line_items_data, footer]
          table(table_data, cell_style: { size: 9, font: "Helvetica", align: :center, :padding => [2, 4, 2, 4]}, column_widths: TABLE_WIDTHS) do
            cells.borders = [:top]
            row(0).font_style = :bold
            row(0).align = :center
            column(2).align = :center
            column(3).align = :right
            column(4).align = :right
            column(5).align = :right
          end
          move_down 25
        end
      end
      move_down 10
      stroke_horizontal_rule
    end

    def display_credit_line_items_table
      move_down 10
      text "CREDIT TRANSACTIONS", size: 10, style: :bold
      move_down 5
      if @orders.credit.blank?
        text "No orders data.", align: :center
      else
        header = [["DATE", "QTY", "PRODUCT", "SERIAL", "PRICE", "AMOUNT"]]
        table(header, :cell_style => {size: 9, :padding => [2, 4, 2, 4]}, column_widths: TABLE_WIDTHS) do
          cells.borders = []
          row(0).font_style = :bold
          column(1).align = :right
          column(2).align = :center
          column(3).align = :center
          column(4).align = :right
          column(5).align = :right
        end
        stroke_horizontal_rule
        move_down 5
        @orders.credit.each do |order|
          header = ["", "", "", "", "", ""]
          footer = ["", "", "", "", "", ""]
          move_down 3
          text "Invoice Number: #{order.invoice_number.number}", size: 9, style: :bold
          line_items_data = order.line_items.map { |e| [ 
                e.created_at.strftime("%B %e, %Y"), 
                "#{e.quantity} #{e.stock.product.unit}", 
                e.stock.product.name_and_description, 
                e.stock.try(:serial_number), 
                price(e.unit_price), 
                price(e.total_price) 
              ]}

          table_data = [header, *line_items_data, footer]
          table(table_data, cell_style: { size: 9, font: "Helvetica", align: :center, :padding => [2, 4, 2, 4]}, column_widths: TABLE_WIDTHS) do
            cells.borders = [:top]
            row(0).font_style = :bold
            row(0).align = :center
            column(0).align = :left
            column(1).align = :right
            column(3).align = :right
            column(4).align = :right
            column(5).align = :right
          end
        end
      end
    end

    def footer_for_itworx
      bounding_box([10, 5], :width => 500, :height => 110) do
        stroke_horizontal_rule
        move_down 5
        text 'This establsihment is  supported by <b>ITWORX POINT-OF- SALE SYSTEM.</b>', size: 8, align: :center, align: :center
        text 'Developed by <b> ITWORX TECHNOLOGY SERVICES</b> Email us at <b> vc.halip@gmail.com </b> Contact # <b> 0927 4173 271</b>', size: 8, align: :center, align: :center
      end
    end
  end
end
