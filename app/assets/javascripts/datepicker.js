$(document).ready(function() {
  $('.datepicker').datetimepicker({
  	format: 'YYYY-MM-DD hh:mm A',
  	showClose: true,
      widgetPositioning: {
            horizontal: 'auto',
            vertical: 'auto'
      }
  });
});

$(document).ready(function() {
  $('.datepicker-reporting').datetimepicker({
  	format: 'YYYY-MM-DD',
  	showClose: true,
      widgetPositioning: {
            horizontal: 'auto',
            vertical: 'auto'
      }
  });
});