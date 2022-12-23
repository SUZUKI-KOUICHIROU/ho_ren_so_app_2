/*global $*/

$(document).on('turbolinks:load', function(){
  // 報告投稿ページ(プロジェクトのセレクトボックスの選択肢に応じて報告フォームを変化させる処理)
  $(function($) {
    $('.box-project-report').on('change', '.reprt-project-select-box', function(){

      // data属性のuser_idを取得
      var user_id = $(this).data('userId');

      // select_boxの値を取得
      var project_id = $(this).val();

      $.ajax({
        url: '/report_forms/report_form_switching',
        data: { user_id: user_id,
                project_id: project_id,
        },
      })
    });
  });
});

jQuery(document).on("turbolinks:load", function () {
  // 報告状況履歴ページのモーダル表示時に行クリックで報告詳細に飛ばす処理
  $(".view-report-log-link").on('click', function() {
      window.location = $(this).data("href");
  });
});