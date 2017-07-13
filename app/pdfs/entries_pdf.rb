class EntriesPdf < Prawn::Document
  TABLE_WIDTHS = [80, 170, 70, 80, 85, 85]
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
  text "#{Business.last.name}", style: :bold, size: 10, align: :center
  text "#{Business.last.address}", size: 10, align: :center
  move_down 15
  text "JOURNAL ENTRIES", style: :bold, size: 10, align: :center
  move_down 3
  text "#{@from_date.strftime("%B %e, %Y")} - #{@to_date.strftime("%B %e, %Y")}", size: 9, align: :center
  move_down 5
  stroke_horizontal_rule
  end


  def display_entries_table
    if @entries.blank?
      move_down 10
      text "No  data.", align: :center
    else
      move_down 10

      table(table_data, header: true, cell_style: { size: 8, font: "Helvetica"}, column_widths: TABLE_WIDTHS) do
        row(0).font_style = :bold
        row(0).background_color = 'DDDDDD'
      end
    end
  end

  def table_data
    move_down 5
    [["DATE", "DESCRIPTION", "AMOUNT", "EMPLOYEE", "DEBIT", "CREDIT"]] +
    @table_data ||= @entries.map { |e| [e.date.strftime('%B %e, %Y'), e.description, price(e.debit_amounts.sum(:amount)), e.recorder.try(:name), e.debit_accounts.pluck(:name).join(', '), e.credit_accounts.pluck(:name).join(', ')

]}
  end
end
