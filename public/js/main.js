(function($) {

  $(function() {
    addSearchBehavior();
  });

  function addSearchBehavior() {
    $('#search').click(function() {
      var postData = {
        name: this.value
      }

      $.post('/stocks', postData, function(data) {
        updateSearchResult(data);
      });

      return false;
    });
  }

  function updateSearchResult(data) {
    $('#search_result').html(data);
  }
})(jQuery);