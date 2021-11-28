/*global $*/

// Rails4では Turbolinks が動作していて、この書き方でないと ready イベントが発火しない
$(document).on('turbolinks:load', function(){
  // フォーム新規登録用モーダルウインドウ(selectboxの入力フォールドが変化したら、パーシャルファイルを変更する処理)
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

  // フォーム新規登録用モーダルウインドウ
  $(function($) {
    //選択肢追加ボタンが押された時option入力フィールドを追加する処理
    // モーダルウインドウは元のhtmlに追加される要素なので、親となる要素にonメソッド繋げる形で記述
    $('#form-new').on('click', '.new-add-field', function(event){
      // 現在時刻をミリ秒形式で取得
      var time = new Date().getTime()
      // ヘルパーで作ったインデックス値を↑と置換
      var regexp = new RegExp($(this).data('id'), 'g')
      // ヘルパーから渡した fields(HTML) を挿入
      $('.new-option-form').append($(this).data('fields').replace(regexp, time))
      event.preventDefault()
    });

    // 削除ボタンが押された時option入力フィールドを削除する処理
    $('#form-new').on('click', '.new-remove-field', function(event){
      // 削除ボタンが押されたフィールドを消す
      $(this).closest('div').remove()
      event.preventDefault()
    });
  });

  // フォーマット編集用ページ
  $(function($) {
    //選択肢追加ボタンが押された時option入力フィールドを追加する処理
    // ボタンのDOM要素を取得
    var btn = document.getElementsByClassName('edit-add-field');
    // ボタンの個数分ループさせる。変数「i」に現在のループ回数がを代入
    for (var i = btn.length - 1; i >= 0; i--) {
      // 各ボタンをイベントリスナーに登録
      btn[i].addEventListener("click", function(event){
        // 差し替え用のinput要素(text_field)を生成する関数
        function buildOptionTextField(form_type, form_object_id, option_id) {
          const option_html = `<input class="form-control required="required" "type="text" value="" name="[${form_type}][${form_object_id}][${form_type}_option_strings][${option_id}][option_string]" id="_${form_type}_${form_object_id}_${form_type}_option_strings_${option_id}_option_string">`;
          return option_html;
        }
        // 差し替え用のinput要素(hidden_field)を生成する関数
        function buildDestroyHiddenField(form_type, form_object_id, option_id) {
          const destroy_hidden_html = `<input class="form-destroy-flag "type="hidden" value="false" name="[${form_type}][${form_object_id}][${form_type}_option_strings][${option_id}][_destroy]" id="_${form_type}_${form_object_id}_${form_type}_option_strings_${option_id}__destroy">`;
          return destroy_hidden_html;
        }
        // クリックされたボタンの親のを取得
        // thisは、クリックされたオブジェクト
        var btn_parent = this.parentNode;
        // クリックされたボタンの親の親を取得
        var btn_parent_parent = btn_parent.parentNode;
        // クリックされたボタンの親の親の最初の子を取得してクローン
        var clone_option_box = btn_parent_parent.firstElementChild.cloneNode(true);
        // 差し替え用のinput要素を生成するのに必要な変数を定義(この変数達は関数であるbuildOptionTextField並びにbuildDestroyHiddenField内で使用)
        // data-form-typeのの値を取得
        form_type = clone_option_box.dataset.formType;
        // data-form-object-idのの値を取得
        form_object_id = clone_option_box.dataset.formObjectId;
        // 現在時刻をミリ秒形式で取得(これをoption_stringのidとして使用)
        option_id = new Date().getTime()
        // クローンしたDMOのtype属性が'text'のinput要素を取得
        var option_input_field = clone_option_box.querySelector("input[type='text']");
        // 取得したinput要素を生成した差し替え用のinput要素に変更
        option_input_field.outerHTML = buildOptionTextField(form_type, form_object_id, option_id);
        // クローンしたDMOのclass属性が'create-flag'のinput要素を取得する
        var create_hidden_field = clone_option_box.querySelector("input[class='create-flag']");
        // 取得したinput要素のvalue値をtrueにする
        create_hidden_field.setAttribute("value", true);
        // クローンしたDMOのclass属性が'destroy-flag'のinputを取得する
        var hidden_destroy_field = clone_option_box.querySelector("input[class='destroy-flag']");
        // 取得したinput要素を生成した差し替え用のinput要素に変更
        hidden_destroy_field.outerHTML = buildDestroyHiddenField(form_type, form_object_id, option_id);
        // 編集したDOMを追加
        $(btn_parent).before(clone_option_box);
        $(clone_option_box).closest('div').show()
        // フォームが持つデフォルトの動作をキャンセル
        event.preventDefault()
      });
    }

    // 削除ボタンが押された時option入力フィールドを削除する処理(name属性がcreateのinput要素のvalue値がによって処理を分岐)
    $('.edit-option-form').on('click', '.edit-remove-field', function(event){
      create_hidden_field_value = $(this).prevAll('input[name*=create]').val()
      console.log(create_hidden_field_value);
      if (create_hidden_field_value == "true")
      {
        $(this).closest('div').remove()
        event.preventDefault()
      }
      else if (create_hidden_field_value == "false")
      {
        $(this).prev('input[name*=_destroy]').val('true')
        $(this).closest('div').hide()
        event.preventDefault()
      }
    });
  });
});

// console.log(true);
