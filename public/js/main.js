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
        updateSearchResult(data);
      });

      return false;
    });
  }

  function updateSearchResult(data) {
    $('#search_result').html(data);
  }

  function isInputValid(value) {
    return $.trim(value) !== "";
  }
})(jQuery);