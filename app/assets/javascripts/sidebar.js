/*global $*/

// ドロワーメニューの利用宣言
$(document).on('turbolinks:load', function(){
  $(document).ready(function() {
    $('.drawer').drawer();
  });
});
