
/*global $*/

// プロジェクト新規作成モーダルウインドウ(報告頻度の入力フォールドが変化したら、次回報告日を動的に算出する処理)
$(function($) {
  // モーダルウインドウは追加される元のhtmlのに追加される処理なので、親となる要素にonメソッド繋げる形で記述
  $('#project-new').on('change', '#project_project_report_frequency', function(){
    // この関数の
    var frequency = $(this).val();
    console.log(frequency);

    // 本日の日付を取得しproject_next_report_date変数に代入
    var project_next_report_date = new Date();
    console.log( "取得したdateインスタンス情報：", project_next_report_date );

    // f取得した本日の日付をfrequencyの値分の加算した日付を取得
    project_next_report_date.setDate( project_next_report_date.getDate() + Number( frequency ));
    console.log( "加算後のdateインスタンス情報：", project_next_report_date );

    var yearNum = project_next_report_date.getFullYear();
    var monthNum = project_next_report_date.getMonth() + 1;
    var dayNum = project_next_report_date.getDate();
    var weekNum = project_next_report_date.getDay();
    var week = [ "日", "月", "火", "水", "木", "金", "土" ][weekNum];
    var jpDateStr = String( yearNum ) + "年"
                      + String( monthNum ) + "月"
                      + String( dayNum ) + "日"
                      + "(" + String( week ) + ")";
    console.log( "次回報告日は、", jpDateStr );
    document.getElementById("project_next_report_date").innerText = `次回報告日：${jpDateStr}`;
  });
});
