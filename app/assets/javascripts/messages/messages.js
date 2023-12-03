/*global $*/

$(document).on('turbolinks:load', function(){  
  $(".send-to").show();

  $("#message_importance").change(function() {
    var selectedImportance = $(this).val();
    switch (selectedImportance) {
      case '高':
        $(".send-to .collection-check-boxes").fadeOut();
        break;
      default:
        $(".send-to .collection-check-boxes").fadeIn();
    }
  });
});
