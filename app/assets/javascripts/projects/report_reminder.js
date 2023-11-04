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

  function setReminder(memberId) {
    // 選択した時刻で「設定」する処理
    var selectedTime = document.getElementById("timeInput" + memberId).value;

    // 時刻設定時にフラッシュメッセージを表示
    alert("報告リマインドの設定が完了しました。");

    // 報告リマインド用に設定した時刻をサーバーに送信
    var selectedTime = document.getElementById("timeInput" + memberId).value;
    fetch('/send_reminder', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': '<%= form_authenticity_token.to_s %>'
        },
        body: JSON.stringify({ memberId: memberId, reportTime: selectedTime })
    })
    .then(response => response.json())
    .then(data => {
        console.log(data);
    })
    .catch(error => console.error('Error:', error));
  }
});
