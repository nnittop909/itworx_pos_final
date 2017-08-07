function calculateChange() {
  var totalAmount = document.getElementById('total').value;
  var cashTendered = document.getElementById('order_cash_tendered').value;
  var discount = document.getElementById('order_discount_attributes_amount').value;

  var change = document.getElementById('order_change');
  var myResult = cashTendered - totalAmount + parseFloat(discount);
  change.value = myResult;
}
