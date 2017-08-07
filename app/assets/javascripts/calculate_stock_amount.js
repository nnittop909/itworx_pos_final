function calculateStockAmount() {
  var qty = document.getElementById('quantity').value;
  var prc = document.getElementById('price').value;

  var ttl = document.getElementById('total');
  var myResult = qty * prc;
  ttl.value = myResult;
}
