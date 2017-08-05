module Members
  class AccountDetailsPdf < Prawn::Document
    TABLE_WIDTHS = [80, 50, 140, 80, 80, 100]
    HEADING_WIDTHS = [100,100,100,100, 100]
    def initialize(member, view_context)
      super(margin: 40, page_size: [612, 1008], page_layout: :portrait)
      @member = member
      @view_context = view_context
      logo
      heading
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
        text "<b>#{Business.last.try(:name)}</b>", size: 10, inline_format: true
        text "Proprietor: #{Business.last.try(:proprietor)}", size: 10, inline_format: true
        text "TIN: #{Business.last.try(:tin)}", size: 10, inline_format: true
        text "Contact #: #{Business.last.try(:mobile_number)}", size: 10, inline_format: true
        text "Email: #{Business.last.try(:email)}", size: 10, inline_format: true
      end
    end
    def heading
     move_down 10
      text "ACCOUNT RECEIVABLE REPORT", align: :center, style: :bold
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
      [["CUSTOMER:", "#{@member.full_name}", ""]] +
      [["#{@member.address}", "", "" ]] +
      [["#{@member.mobile}", "", "", "AMOUNT", "#{price(@member.total_credit)}" ]] +
      [["", "", "", "INTEREST", "#{price(@member.total_credit_interest)}" ]] +
        [["", "", "", "PAYMENT", "#{price(@member.total_payment)}" ]] +
      [["", "", "", "BALANCE", "#{price(@member.total_remaining_balance)}" ]]
      

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
      @cash_data ||= @member.line_items.cash.map { |e| [e.created_at.strftime("%B %e, %Y %I:%M %p"), e.quantity, e.stock.try(:name), e.stock.try(:serial_number), e.unit_cost, e.total_cost]}
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
    @credit_data ||= @member.line_items.credit.map { |e| [e.created_at.strftime("%B %e, %Y %I:%M %p"), e.quantity, e.stock.try(:name), e.stock.try(:serial_number), e.unit_cost, e.total_cost]}
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
