$(document).ready(function() {
	$('#define_price').click(function() {
    if ( $('#define_price:checked').length > 0) {
      $("#line_item_unit_cost").removeAttr('readonly');
    } else {
      $("#line_item_unit_cost").attr('readonly','readonly');
    }
  }); 
});