class EntriesPdf < Prawn::Document
  TABLE_WIDTHS = [80, 130, 60, 80, 110, 112]
def initialize(entries, from_date, to_date, view_context)
  super(margin: 20, page_size: [612, 1008], page_layout: :portrait)
  @entries = entries
  @from_date = from_date
  @to_date = to_date
  @view_context = view_context
  heading

  display_entries_table
end

def price(number)
  @view_context.number_to_currency(number, :unit => "P ")
end


def heading
  text "#{Business.last.name}", style: :bold, size: 11, align: :center
  text "#{Business.last.address}", size: 10, align: :center
  move_down 15
  text "JOURNAL ENTRIES", style: :bold, size: 11, align: :center
  move_down 3
  if @from_date.strftime("%B %e, %Y") == @to_date.strftime("%B %e, %Y")
    text "#{@from_date.strftime("%B %e, %Y")}", size: 9, align: :center
  else
    text "#{@from_date.strftime("%B %e, %Y")} - #{@to_date.strftime("%B %e, %Y")}", size: 9, align: :center
  end
  move_down 5
  stroke_horizontal_rule
  end


  def display_entries_table
    if @entries.blank?
      move_down 10
      text "No  data.", align: :center
    else
      move_down 10

      header = [["DATE", "DESCRIPTION", "EMPLOYEE", "AMOUNT", "DEBIT", "CREDIT"]]
      table(header, :cell_style => {size: 9, :padding => [2, 4, 2, 4]}, column_widths: TABLE_WIDTHS) do
        cells.borders = []
        row(0).font_style = :bold
        column(3).align = :right
      end
      stroke_horizontal_rule

      header = ["", "", "", "", "", ""]
      footer = ["", "", "", "", "", ""]
      entries_data = @entries.map { |e| [e.date.strftime("%b %e, %Y \n %I:%M %p"), e.description, e.recorder.try(:name), price(e.debit_amounts.pluck(:amount).join("\n")), e.debit_accounts.pluck(:name).join("\n"), e.credit_accounts.pluck(:name).join("\n")]}
      table_data = [header, *entries_data, footer]
      table(table_data, cell_style: { size: 9, font: "Helvetica", inline_format: true, :padding => [2, 4, 2, 4]}, column_widths: TABLE_WIDTHS) do
        cells.borders = [:top]
        row(0).font_style = :bold
        column(3).align = :right
      end
    end
  end
end
