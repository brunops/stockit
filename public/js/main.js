(function($) {

  $(function() {
    addSearchBehavior();
  });

  function addSearchBehavior() {
    var inputEl = $('#search_input'),
        isResquestBeingPerformed = false;
    $('#search').click(function() {
      if (!isInputValid(inputEl.val()) || isResquestBeingPerformed) {
        return false;
      }
      isResquestBeingPerformed = true;

      var postData = {
        name: inputEl.val()
      }

      $.post('/stocks', postData, function(data) {
        data = JSON.parse(data);

        updateSearchResult($.trim(inputEl.val()).toUpperCase(), data.chart_data);
        updateProbabilityResult(data.probability);

        isResquestBeingPerformed = false;
      });

      return false;
    });
  }

  function updateProbabilityResult(probability) {
    $('.future_projections').css('visibility', 'visible');
    $('#probability').html('<span class="' + probability[1] + '">' + probability[0] + '</span>');
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