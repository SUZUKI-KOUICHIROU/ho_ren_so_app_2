$(document).on('turbolinks:load', function(){

  // CSRFトークンの取得
  var csrfToken = $('meta[name=csrf-token]').attr('content');

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

  // 報告リマインドで選択した時刻を設定する処理
  $(function($) {
    $('.set-reminder').on('click', function() {
      // report_time の値を設定
      var timeInput = $(this).closest('.project-member-action').find('.form-control');
      var reportTime = timeInput.val();
  
      // ユーザーIDとプロジェクトIDを取得
      var userId = $(this).data('user-id');
      var projectId = $(this).data('project-id');

      // Ajaxリクエストを送信
      $.ajax({
        url: '/projects/members/send_reminder',
        type: 'POST',
        data: { user_id: userId, project_id: projectId, member_id: $(this).data('member-id'), report_time: reportTime },

        // CSRFトークンをリクエストヘッダに含める
        headers: {
          'X-CSRF-Token': csrfToken
        },
        success: function(data) {
          // 成功時の処理
          alert("報告リマインドの設定が完了しました。");
        },
        error: function() {
          // エラー時の処理
          alert("報告リマインドの設定でエラーが発生しました。");
        }
      });
    });
  });
});
