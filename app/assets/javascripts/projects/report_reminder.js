$(document).on('turbolinks:load', function(){
  function setReminder(memberId) {
    // TODO: 時刻選択の処理を追加

    // フラッシュメッセージの表示
    alert("報告リマインドの設定が完了しました。");
  }

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
