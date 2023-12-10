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

  // 報告リマインドの日にち選択肢を報告頻度に応じて反映させる処理
  $(function($) {
    // メンバー一覧画面からデータを取得
    var reportFrequencies = $('.project-member-action').map(function() {
      return parseInt($(this).data('report-frequency'));
    }).get();

    // 日にち選択肢を制御する関数
    function updateReminderOptions() {
      // 日にち選択肢の親要素を取得
      $('.project-member-action').each(function(index) {
        var selectElement = $(this).find('.form-control');
        var reportFrequency = reportFrequencies[index];

        // 日にち選択肢を一旦クリア
        selectElement.html('');

        // 報告頻度に応じて日にち選択肢の最大値を設定
        var optionsCount = reportFrequency;

        // 日にち選択肢を生成して追加
        for (var i = 0; i < optionsCount; i++) {
          var option = $('<option>').val(i).text(i === 0 ? '当日' : i + '日前');
          if (i === 0) {
            option.attr('selected', true);
          }
          selectElement.append(option);
        }
      });
    }

    // メンバー一覧画面の読込み時に日にち選択肢を更新
    updateReminderOptions();

    // 報告頻度の変更が起きた際に日にち選択肢を再更新
    $('.project-member-action .custom-control-input').on('change', updateReminderOptions);
  });

  // 報告リマインドで選択した日にち＆時刻を設定する処理
  $(function($) {
    $('.set-reminder').on('click', function() {
      // ユーザーIDとプロジェクトIDを取得
      var userId = $(this).data('user-id');
      var projectId = $(this).data('project-id');
      
      // 報告頻度の設定
      var reportFrequency = $(this).closest('.project-member-action').data('report-frequency');

      // reminderDays と report_time の値を設定
      var reminderDays = $(this).closest('.project-member-action').find('select').val();
      var timeInput = $(this).closest('.project-member-action').find('.form-control');
      var reportTime = timeInput.val();

      // Ajaxリクエストを送信
      $.ajax({
        url: '/projects/members/send_reminder',
        type: 'POST',
        data: {
          user_id: userId,
          project_id: projectId,
          member_id: $(this).data('member-id'),
          report_frequency: reportFrequency, // 報告頻度を追加
          reminder_days: reminderDays,
          report_time: reportTime
        },

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
