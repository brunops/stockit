(function($) {

  $(function() {
    //addSearchBehavior();

    $('#search').on('click', function(){
      $('#search_result').append("1.20");
      // $('#search_result').append("<img class='up_arrow animated css' src='https://cdn1.iconfinder.com/data/icons/musthave/256/Stock%20Index%20Up.png'/>")
      $('#graph_result').append("<img src='http://www.onlineproxy.com/burlington/2000/p-img/stock-graph-1.gif'/>");
    });
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