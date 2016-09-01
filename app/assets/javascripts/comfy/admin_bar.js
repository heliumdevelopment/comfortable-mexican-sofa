$(function() {
  function expirePage() {
    var $expire = $('#expire-template');

    $.ajax({
      url: $expire.attr('action'),
      method: 'post',
      data: $expire.serialize(),
      success: function(response) {
        location.reload();
      },
    });
  }

  // Only show if admin
  $.getJSON('/backend/admin_editable', function(admin) {
    if (admin) {
      // If we're not an admin in the page, we know we're working off an old
      // cached copy it. Bust it and reload.
      if (!App.admin) {
        expirePage();
      } else {
        $('body').addClass('admin');
        phrasing_setup();
      }
    }
  });
});
