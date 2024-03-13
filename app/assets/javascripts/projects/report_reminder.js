$(document).on('turbolinks:load', function(){

  // CSRFトークンの取得
  var csrfToken = $('meta[name=csrf-token]').attr('content');

  // 報告リマインド切替スイッチの状態が変化したら実行する処理
  $(function($) {
    $('.project-member-action').on('change', '.custom-control-input', function(){
      var reminderSettingContainer = $(this).closest('.project-member-action').find('.reminder-setting');
      var selectElement = reminderSettingContainer.find('.form-control');

      // 切替スイッチがオンの場合、リマインド設定を表示
      if (this.checked) {
        reminderSettingContainer.show();
        selectElement.prop('disabled', false);

        // 選択日数の選択を解除（デフォルト化）
        var optionsCount = parseInt($(this).closest('.project-member-action').data('report-frequency'));
        selectElement.html('');
        for (var i = 0; i < optionsCount; i++) {
          var option = $('<option>').val(i).text(i === 0 ? '当日' : i + '日前');
          if (i === 0) {
            option.attr('selected', true);
          }
          selectElement.append(option);
        }

      // 切替スイッチがオフの場合の場合、リマインド設定を非表示＆解除
      } else {
        reminderSettingContainer.hide();
        selectElement.prop('disabled', true);
  
        var userId = $(this).data('user-id');
        var projectId = $(this).data('project-id');
        var memberId = $(this).data('member-id');

        // 選択時刻の選択を解除
        var timeInput = $(this).closest('.project-member-action').find('.form-control[type="time"]');
        timeInput.val('');  // デフォルトの選択をクリア

        // 設定をリセットするAjaxリクエストを送信
        $.ajax({
          url: '/projects/members/reset_reminder',
          type: 'POST',
          data: {
            user_id: userId,
            project_id: projectId,
            member_id: memberId
          },
          headers: {
            'X-CSRF-Token': csrfToken
          },
          success: function(data) {
            // 成功時の処理
            alert("報告リマインドの設定をリセットしました。\n\n【注意】\n既に完了済の設定は 1ヶ月間 解除されません。");
          },
          error: function() {
            // エラー時の処理
            alert("エラーが発生したため、報告リマインド設定をリセット出来ませんでした。");
          }
        });
      }
    });
  });

  // 報告リマインドの日にち選択肢を報告頻度に応じて反映させる処理
  $(function($) {
    // メンバー一覧画面からデータを取得
    var reportFrequencies = $('.project-member-action').map(function() {
      return {
        reportFrequency: parseInt($(this).data('report-frequency')),
        selectedDays: parseInt($(this).find('.form-control').data('selected-days'))
      };
    }).get();

    // 日にち選択肢を制御する関数
    function updateReminderOptions() {
      // 日にち選択肢の親要素を取得
      $('.project-member-action').each(function(index) {
        var reminderSettingContainer = $(this).find('.reminder-setting');
        var selectElement = reminderSettingContainer.find('.form-control');

        var reportFrequency = reportFrequencies[index].reportFrequency;
        var selectedDays = reportFrequencies[index].selectedDays;

        // 日にち選択肢を一旦クリア
        selectElement.html('');

        // 報告頻度に応じて日にち選択肢の最大値を設定
        var optionsCount = reportFrequency;

        // 選択日数の値を取得
        var reminderDays = parseInt($(this).data('selected-days'));

        // 報告リマインドが設定済の場合、設定済の選択日数＆選択時刻を初期表示するよう生成
        if (reminderDays !== null) {
          for (var i = 0; i < optionsCount; i++) {
            var option = $('<option>').val(i).text(i === 0 ? '当日' : i + '日前');
            if (i === selectedDays) {
              option.attr('selected', true);
            }
            selectElement.append(option);
          }
          // 時刻選択用の<input>要素を取得
          var timeInput = reminderSettingContainer.find('input[type="time"]');

        // 報告リマインドが未設定の場合、デフォルトの日にち選択肢＆時刻選択肢を生成
        } else {
          for (var i = 0; i < optionsCount; i++) {
            var option = $('<option>').val(i).text(i === 0 ? '当日' : i + '日前');
            if (i === 0) {
              option.attr('selected', true);
            }
            selectElement.append(option);
          }
          // 時刻選択用の<input>要素を取得
          var timeInput = reminderSettingContainer.find('input[type="time"]');
          timeInput.val('');  // デフォルトの選択をクリア
        }

        // 時刻選択肢を再生成
        var timeOption = $('<option>').val('').text('');  // デフォルトの選択
        timeInput.append(timeOption);
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
      
      // 報告頻度（report-frequency）の値を取得
      var reportFrequency = $(this).closest('.project-member-action').data('report-frequency');

      // 選択した日数（reminderDays）の値を設定
      var reminderDays = $(this).closest('.project-member-action').find('select').val();

      // 選択した時刻（report_time）の値を設定
      var timeInput = $(this).closest('.project-member-action').find('.form-control[type="time"]');
      var reportTime = timeInput.val();
  
      // 報告リマインドを設定するAjaxリクエストを送信
      $.ajax({
        url: '/projects/members/send_reminder',
        type: 'POST',
        data: {
          user_id: userId,
          project_id: projectId,
          member_id: $(this).data('member-id'),
          report_frequency: reportFrequency,
          reminder_days: reminderDays,
          report_time: reportTime
        },

        // CSRFトークンをリクエストヘッダに含める
        headers: {
          'X-CSRF-Token': csrfToken
        },
        success: function(data) {
          // 成功時の処理
          alert("報告リマインドの設定が完了しました。\n\n設定は 1ヶ月間 有効です。");
        },
        error: function() {
          // エラー時の処理
          alert("報告リマインドの設定でエラーが発生しました。\n\n設定には日時の選択が両方とも必要です。");
        }
      });
    });
  });
});
