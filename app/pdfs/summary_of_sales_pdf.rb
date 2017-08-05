class SummaryOfSalesPdf < Prawn::Document
  TABLE_WIDTHS = [40, 75, 75, 75, 75, 80, 80, 70 ]
  def initialize(stocks, orders, from_date, to_date, view_context)
    super(margin: 20, page_size: [612, 1008], page_layout: :portrait)
    @orders = orders
    @stocks = stocks
    @from_date = from_date
    @to_date = to_date
    @view_context = view_context

    @sales  = Accounting::Account.find_by_name("Sales")
    @sales_return  = Accounting::Account.find_by_name("Sales Returns and Allowances")
    @cash_on_hand  = Accounting::Account.find_by_name("Cash on Hand")
    @credits = Accounting::Account.find_by_name('Accounts Receivables Trade - Current')
    @payables = Accounting::Account.find_by_name('Accounts Payable-Trade')
    @purchases = Accounting::Account.find_by_name("Merchandise Inventory")
    @expenses = Accounting::Expense.where.not(id: 193).where.not(id: 9).all
    @cost_of_goods_sold  = Accounting::Account.find_by_name("Cost of Goods Sold")
    heading
    display_orders_table

  end
  def price(number)
    @view_context.number_to_currency(number, :unit => "P ")
  end
  def heading
    text "#{Business.last.try(:name)}", size: 8
    text "#{Business.last.try(:proprietor)}", size: 8
    text "#{Business.last.try(:tin)}", size: 8
    text "#{Business.last.try(:address)}", size: 8


    text 'SUMMARY REPORT', size: 12, align: :center, style: :bold
    text "#{@from_date.strftime("%B %d, %Y")} - #{@to_date.strftime("%B %d, %Y")}", size: 9, align: :center
    move_down 3
    stroke_horizontal_rule
    move_down 10

  end


  def oldest?
    if Accounting::Entry.any?
      @entries = Accounting::Entry.all.map { |entry| entry["date"] }
      @entries.min.beginning_of_day
    end
  end

  def previous_a_r_payments
    if Accounting::Entry.any?
      @credits.credits_balance({from_date: oldest?, to_date: @from_date.yesterday.end_of_day})
    end
  end

  def current_a_r_payments
    if Accounting::Entry.any?
      @credits.credits_balance({from_date: @from_date.yesterday.end_of_day, to_date: @to_date.end_of_day})
    end
  end

  def previous_account_recievables
    if Accounting::Entry.any?
      @credits.balance({from_date: oldest?, to_date: @from_date.yesterday.end_of_day})
    end
  end

  def current_account_recievables
    if Accounting::Entry.any?
      @credits.balance({from_date: @from_date.yesterday.end_of_day, to_date: @to_date.end_of_day})
    end
  end

  def expenses
    if Accounting::Entry.any?
      @expenses.balance({from_date: @from_date.yesterday.end_of_day, to_date: @to_date.end_of_day})
    end
  end

  def total_sales
    if Accounting::Entry.any?
      sales = @sales.balance({from_date: @from_date.yesterday.end_of_day, to_date: @to_date.end_of_day})
      sales_return = @sales_return.debits_balance({from_date: @from_date.yesterday.end_of_day, to_date: @to_date.end_of_day})
      credits = @credits.debits_balance({from_date: @from_date.yesterday.end_of_day, to_date: @to_date.end_of_day})
      sales - sales_return
    end
  end

  def total_purchases
    if Accounting::Entry.any?
      @purchases.debits_balance({from_date: @from_date.yesterday.end_of_day, to_date: @to_date.end_of_day}) - 
      @purchases.credits_balance({from_date: @from_date.yesterday.end_of_day, to_date: @to_date.end_of_day}) +
      @cost_of_goods_sold.debits_balance({from_date: @from_date.yesterday.end_of_day, to_date: @to_date.end_of_day})
    end
  end

  def previous_cash_on_hand
    if Accounting::Entry.any?
      @cash_on_hand.debits_balance({from_date: oldest?, to_date: @from_date.yesterday.end_of_day})
    end
  end

  def current_cash_on_hand
    if Accounting::Entry.any?
      @cash_on_hand.debits_balance({from_date: @from_date.yesterday.end_of_day, to_date: @to_date.end_of_day})
    end
  end

  def payables_beginning
    if Accounting::Entry.any?
      @payables.balance({from_date: oldest?, to_date: @from_date.yesterday.end_of_day})
    end
  end

  def payables_ending
    if Accounting::Entry.any?
      @payables.balance({from_date: @from_date.yesterday.end_of_day, to_date: @to_date.end_of_day})
    end
  end

  def starting_inventory
    if Accounting::Entry.any?
      @purchases.debits_balance({from_date: oldest?, to_date: @from_date.yesterday.end_of_day}) - 
      @purchases.credits_balance({from_date: oldest?, to_date: @from_date.yesterday.end_of_day})
    end
  end

  def ending_inventory
    if Accounting::Entry.any?
      starting_inventory - 
      @purchases.credits_balance({from_date: @from_date.yesterday.end_of_day, to_date: @to_date.end_of_day})
    end
  end

  def starting_balance
    @cash_on_hand.balance({from_date: oldest?, to_date: @from_date.yesterday.end_of_day})
  end

  def outstanding_balance
    @cash_on_hand.balance({from_date: oldest?, to_date: @to_date.end_of_day})
  end

  def net_surplus
    Accounting::Revenue.balance({from_date: @from_date.yesterday.end_of_day, to_date: @to_date.end_of_day}) - 
    Accounting::Expense.balance({from_date: @from_date.yesterday.end_of_day, to_date: @to_date.end_of_day})
  end

  def display_orders_table
    if Accounting::Entry.blank?
      move_down 10
      text "No orders data.", align: :center
    else
      move_down 10
      table_title = [["Cash on Hand, Beginning: ", "#{(price starting_balance)}", "", "Beginning Inventory: ", "#{(price starting_inventory)}"],
                  ["Cash on Hand, Ending: ", "#{(price outstanding_balance)}", "", "Ending Inventory: ", "#{(price ending_inventory)}"],
                  ["Sales: ", "#{(price total_sales)}", "", "Purchases: ", "#{(price total_purchases)}"],
                  ["Accounts Receivables, Beg.: ", "#{(price previous_account_recievables)}", "", "Expenses: ", "#{(price expenses)}"],
                  ["Accounts Receivables, Ending.: ", "#{(price current_account_recievables)}", "", "", "" ],
                  ["Accounts Payables, Beg.: ", "#{(price payables_beginning)}", "", "", "" ],
                  ["Accounts Payables, Ending.: ", "#{(price payables_ending)}", "", "Net Surplus:", "#{price(net_surplus)}" ]]
      table(table_title, :cell_style => {size: 9, :padding => [1, 1, 1, 1]}, column_widths: [130, 100, 130, 110, 100]) do
        cells.borders = []
        column(1).font_style = :bold
        column(4).font_style = :bold
        column(1).align = :right
        column(4).align = :right
        row(0).background_color = 'DDDDDD'
        row(1).background_color = 'DDDDDD'
        row(2).background_color = 'DDDDDD'
        row(3).background_color = 'DDDDDD'
        row(4).background_color = 'DDDDDD'
        row(5).background_color = 'DDDDDD'
        row(6).background_color = 'DDDDDD'
      end
      move_down 5
      table(table_data, header: false, cell_style: { size: 8, padding: 3}, column_widths: TABLE_WIDTHS) do
        row(0).font_style = :bold
      # /  row(0).background_color = 'DDDDDD'
        column(1).align = :right
        column(2).align = :right
        column(3).align = :right
        column(4).align = :right
        column(5).align = :right
        column(6).align = :right
        column(7).align = :right

        row(-1).font_style = :bold
        row(-1).size = 11

      end
    end
  end

  def table_data
    move_down 5
    
    [["Date", "Purchase", "Cash Sales", "Charge Sales", "AR Collection", "Operational Expenses", "Total Cash Collection", "Balance"]] +
    @table_data ||= (@from_date..@to_date).map { |e| 
      if Accounting::Entry.entered_on({from_date: e.to_date.beginning_of_day, to_date: e.to_date.end_of_day}).any?
        [e.strftime("%d"), 
        "#{price (purchases = @purchases.debits_balance(from_date: e.to_date.beginning_of_day, to_date: e.to_date.end_of_day) - @purchases.credits_balance(from_date: e.to_date.beginning_of_day, to_date: e.to_date.end_of_day) + @cost_of_goods_sold.debits_balance(from_date: e.to_date.beginning_of_day, to_date: e.to_date.end_of_day))}", 
        "#{price (sales = @orders.cash.created_between(from_date: e.to_date.beginning_of_day, to_date: e.to_date.end_of_day).total_amount_less_discount)}", 
        "#{price (credits = @credits.debits_balance({from_date: e.to_date.beginning_of_day, to_date: e.to_date.end_of_day}))}", 
        "#{price (payments = @credits.credits_balance({from_date: e.to_date.beginning_of_day, to_date: e.to_date.end_of_day}))}",
        "#{price (expenses = @expenses.balance({from_date: e.to_date.beginning_of_day, to_date: e.to_date.end_of_day}))}",
        "#{price (sales + payments - expenses)}",
        "#{price (@cash_on_hand.balance({from_date: oldest?, to_date: e.to_date.end_of_day}))}",]
      else
        [e.strftime("%d"), "_", "_", "_", "_", "_", "_", "_"]
      end
    } +
    [["", "", "", "", "", "", "", ""]]

  end
end
