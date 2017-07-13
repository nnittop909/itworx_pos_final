jQuery ->
  output = $('#accounting_entry_credit_amounts_attributes_0_amount')
  $('#accounting_entry_debit_amounts_attributes_0_amount').keyup (event) ->
    output.val(this.value)
  output_interest = $('#accounting_interest_credit_amounts_attributes_0_amount')
  $('#accounting_interest_debit_amounts_attributes_0_amount').keyup (event) ->
    output_interest.val(this.value)
  output_discount = $('#accounting_discount_credit_amounts_attributes_0_amount')
  $('#accounting_discount_debit_amounts_attributes_0_amount').keyup (event) ->
    output_discount.val(this.value)