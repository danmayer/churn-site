(function ($) {
  console.log('ready')

  $(".chart-loading").load($(".chart-loading").data('url'), function(){
    if($("#BarChart").length > 0) {
      var ctx = $("#BarChart").get(0).getContext("2d");
      var data = $("#BarChart").data('bardata')
      new Chart(ctx).Bar(data);
    }
  });

}(jQuery));
