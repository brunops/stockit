(function($) {

  $(function() {
    addSearchBehavior();
  });

  function addSearchBehavior() {
    var inputEl = $('#search_input');
    $('#search').click(function() {
      if (!isInputValid(inputEl.val())) {
        return false;
      }

      var postData = {
        name: inputEl.val()
      }

      $.post('/stocks', postData, function(data) {
        data = JSON.parse(data);

        updateSearchResult($.trim(inputEl.val()).toUpperCase(), data.chart_data);
        updateProbabilityResult(data.probability);
      });

      return false;
    });
  }

  function updateProbabilityResult(probability) {
    $('#search_result').addClass(probability[1]).html(probability[0]);
  }

  function updateSearchResult(stock, data) {
    $('#result_chart').highcharts('StockChart', {
      rangeSelector : {
        selected : 1
      },

      title : {
        text : stock + ' Stock Percentage Change at Close'
      },

      series : [{
        name : stock,
        data : data,
        tooltip: {
          valueDecimals: 2
        }
      }]
    });
  }

  function isInputValid(value) {
    return $.trim(value) !== "";
  }
})(jQuery);