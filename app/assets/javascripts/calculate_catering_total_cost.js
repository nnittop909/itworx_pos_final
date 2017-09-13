function calculateAmount() {
  var totalAmount = document.getElementById('total-catering-cost').value;
  var totalExpenses = document.getElementById('total-expenses').value;
  var debitAmount = document.getElementById('debit-amount');
  var creditAmount = document.getElementById('credit-amount');

  var myResult = totalAmount - totalExpenses
  debitAmount.value = myResult;
  creditAmount.value = myResult;
}