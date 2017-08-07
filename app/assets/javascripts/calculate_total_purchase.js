function calculateTotalPurchase() {
  var quantity = document.getElementById('stock_quantity').value;
  var unitCost = document.getElementById('stock_unit_cost').value;
  var discount = document.getElementById('discount-amount').value;
  var freight_in = document.getElementById('freight-amount').value;

  var totalCost = document.getElementById('stock_total_cost');
  var myResult = quantity * unitCost + parseFloat(freight_in)- parseFloat(discount);
  totalCost.value = myResult;
}
