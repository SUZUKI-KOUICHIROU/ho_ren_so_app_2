$(document).on('turbolinks:load', function(){

  // 報告リマインド切替スイッチの状態が変化したら実行する処理
  $(function($) {
    $('.project-member-action').on('change', '.custom-control-input', function(){
      var timeInputContainer = $(this).closest('.project-member-action').find('.time-input');
      var timeInput = timeInputContainer.find('.form-control');

      if (this.checked) {
        timeInputContainer.show();
        timeInput.prop('disabled', false);
      } else {
        timeInputContainer.hide();
        timeInput.prop('disabled', true);
      }
    });
  });
});
