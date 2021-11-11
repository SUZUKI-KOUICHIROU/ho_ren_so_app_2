/*global $*/

// Rails4では Turbolinks が動作していて、この書き方でないと ready イベントが発火しない
$(document).on('turbolinks:load', function(){
  // フォーマット新規登録用モーダルウインドウ(selectboxの入力フォールドが変化したら、パーシャルファイルを変更する処理)
  $(function($) {
    // モーダルウインドウは元のhtmlに追加される要素なので、親となる要素にonメソッド繋げる形で記述
    $('#form-new').on('change', '.select-form', function(){
      // selectboxの値を取得しfrequencyに代入
      var form_type = $(this).val();
      console.log(form_type);

      var project_id = $(this).data('projectId');
      console.log(project_id);

      $.ajax({
        url: '/input_forms/replacement_input_forms',
        data: { form_type: form_type,
                project_id: project_id },
      })
    });
  });

  // フォーマット新規登録用モーダルウインドウ(option入力フィールドを追加する処理)
  $(function($) {
    // モーダルウインドウは元のhtmlに追加される要素なので、親となる要素にonメソッド繋げる形で記述
    $('#form-new').on('click', '.add_field', function(event){
      console.log(true);
      // 現在時刻をミリ秒形式で取得
      var time = new Date().getTime()
      console.log(time);
      // ヘルパーで作ったインデックス値を↑と置換
      var regexp = new RegExp($(this).data('id'), 'g')
      console.log(regexp);
      // ヘルパーから渡した fields(HTML) を挿入
      $('.form-view-check-box').append($(this).data('fields').replace(regexp, time))
      event.preventDefault()
    });

    // 削除ボタンを押されたとき
    $('#form-new').on('click', '.remove_field', function(event){
      // 削除ボタンを押したフィールドの _destroy = true にする
      $(this).prev('input[name*=_destroy]').val('true')
      // 削除ボタンが押されたフィールドを隠す
      $(this).closest('div').hide()
      event.preventDefault()
    });
  });
});
