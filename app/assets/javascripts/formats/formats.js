/*global $*/

// Rails4では Turbolinks が動作していて、この書き方でないと ready イベントが発火しない
$(document).on('turbolinks:load', function(){
  // フォーマット編集ページがロードされた時、各項目のoption-boxの表示を切り替える関数
  function optionDisplaySwitch(){
    // document内のclass属性の値がoption-form-editの要素を全て取得
    var edit_option_form = document.getElementsByClassName('option-form-edit');
    console.log(edit_option_form);
    // edit_option_formの数だげ以下をループ処理
    for (var i = edit_option_form.length - 1; i >= 0; i--) {
      // option-form-edit内のclass属性の値がoption-boxの要素を全て取得
      var option_box = edit_option_form[i].querySelectorAll("div[class='option-box']")
      console.log(option_box)
      // class属性の値がoption-boxの要素数をカウント
      var option_box_count = option_box.length;
      console.log(option_box_count)
      // 削除ボタンの表示を切り替え
      // 要素数が1以下の場合以下を実行
      if (option_box_count <= 1) {
        // option_box内のclass属性の値がremove-fieldの要素を取得した後、非表示に
        option_box[0].querySelector("a[class='remove-field']").style.display = 'none';
      }
    }
  }
  // フォーマット編集ページがロードされた時、optionDisplaySwitch(関数)をを実行
  window.addEventListener('load', optionDisplaySwitch);

  // フォーム新規登録用モーダルウインドウ(selectboxの入力フォールドが変化したら、パーシャルファイルを変更する処理)
  $(function($) {
    // モーダルウインドウは元のhtmlに追加される要素なので、親となる要素にonメソッド繋げる形で記述
    $('#form-new').on('change', '.select-form', function(){
      // selectboxの値を取得しfrequencyに代入
      var form_type = $(this).val();

      var project_id = $(this).data('projectId');

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
    $('#form-new').on('click', '.add-field-new', function(event){
      // index差し替え用のinput要素(hidden_field)を生成する関数(id用)
      function buildIdHiddenField(form_table_type_value, option_index) {
        const id_hidden_html =
        `<input type="hidden"
        name="question[${form_table_type_value}_attributes][${form_table_type_value}_option_strings_attributes][${option_index}][id]"
        id="question_${form_table_type_value}_attributes_${form_table_type_value}_option_strings_attributes_${option_index}_id">`;
        return id_hidden_html;
      }

      // index差し替え用のinput要素(text_field)を生成する関数(text_field用)
      function buildOptionTextField(form_table_type_value, option_index) {
        const option_input_html =
        `<input class="form-control format-form-style" required="required" "type="text" value=""
        name="question[${form_table_type_value}_attributes][${form_table_type_value}_option_strings_attributes][${option_index}][option_string]"
        id="question_${form_table_type_value}_attributes_${form_table_type_value}_option_strings_attributes_${option_index}_option_string">`;
        return option_input_html;
      }

      // クリックされたボタンの親のを取得
      // thisは、クリックされたオブジェクト
      var option_add_btn_box = this.parentNode;
      console.log(option_add_btn_box)
      // クリックされたボタンの親の親を取得
      var option_form_new = option_add_btn_box.parentNode;
      console.log(option_form_new)
      // クリックされたボタンの親の親の最初の子を取得してクローン
      var clone_option_box = option_form_new.firstElementChild.cloneNode(true);
      console.log(clone_option_box)
      // 差し替え用のinput要素を生成するのに必要な変数を定義(この変数達は関数であるbuildOptionTextField並びにbuildDestroyHiddenField内で使用)
      // data-form-table-type-valueの値を取得
      var form_table_type_value = clone_option_box.dataset.formTableTypeValue;
      console.log(form_table_type_value)
      // option-boxの要素数を取得(インデックス値は0から始まるため取得値をそのまま使用)
      var option_index = option_form_new.querySelectorAll("div[class='option-box']").length;
      console.log(option_index)
      // クローンしたDMOのtype属性が'hidden'のinput要素を取得
      var id_input_field = clone_option_box.querySelector("input[type='hidden']");
      console.log(id_input_field)
      // 取得したinput要素を生成した差し替え用のinput要素に変更
      id_input_field.outerHTML = buildIdHiddenField(form_table_type_value, option_index);
      // クローンしたDMOのtype属性が'text'のinput要素を取得
      var option_input_field = clone_option_box.querySelector("input[type='text']");
      console.log(option_input_field)
      // 取得したinput要素を生成した差し替え用のinput要素に変更
      option_input_field.outerHTML = buildOptionTextField(form_table_type_value, option_index);
      // data-form-indexの値を変更
      clone_option_box.dataset.formIndex = `${option_index}`;
      // 追加する要素を最終確認
      console.log(clone_option_box)
      // 編集したDOM(clone_option_box)を追加
      $(option_add_btn_box).before(clone_option_box);
      $(clone_option_box).closest('div').show()
      // 削除ボタンの表示を切り替え
      if ($('.option-box').length >= 2) {
        $('.delete-btn-new').show();  // class属性の値が2つ以上あるときに削除ボタンを表示
      }
      // フォームが持つデフォルトの動作をキャンセル
      event.preventDefault()
    });

    // 削除ボタンが押された時option入力フィールドを削除する処理
    $('#form-new').on('click', '.remove-field', function(event){
      // 押された削除ボタンのclass属性の値がoption-form-newの要素を取得
      var option_form_new = $(this).parent().parent();
      console.log(option_form_new)
      // 削除ボタンが押されたフィールドを消す
      $(this).closest('div').remove()
      // option-form-new内のcclass属性の値がoption-boxの要素を全て取得しカウント
      var option_box_count = option_form_new.children('.option-box').length;
      console.log(option_box_count)
      // 削除ボタンの表示を切り替え
      if (option_box_count >= 2) {
        $('.delete-btn-new').show(); // class属性の値がoption-boxの要素が2つ以上あるときに削除ボタンを表示
      } else {
        $('.delete-btn-new').hide(); // それ以外は削除ボタンを非表示
      }
      event.preventDefault()
    });
  });

  // フォーマット編集用ページ
  $(function($) {
    //選択肢追加ボタンが押された時option入力フィールドを追加する処理
    // ボタンのDOM要素を全て取得
    var btn = document.getElementsByClassName('add-field-edit');
    // ボタンの個数分ループさせる。変数「i」に現在のループ回数がを代入
    for (var i = btn.length - 1; i >= 0; i--) {
      // 各ボタンをイベントリスナーに登録(どの項目のボタンが押されたのか特定する為に必要)
      btn[i].addEventListener("click", function(event){
        // index差し替え用のinput要素(hidden_field)を生成する関数(id用)
        function buildIdHiddenField(form_table_type_value, option_index, question_id) {
          const id_hidden_html =
          `<input type="hidden" value=""
          name="[question_attributes][${question_id}][${form_table_type_value}_attributes][${form_table_type_value}_option_strings_attributes][${option_index}][id]"
          id="_question_attributes_${question_id}_${form_table_type_value}_attributes_${form_table_type_value}_option_strings_attributes_${option_index}_id">`;
          return id_hidden_html;
        }

        // index差し替え用のinput要素(text_field)を生成する関数(text_field用)
        function buildOptionTextField(form_table_type_value, option_index, question_id) {
          const option_input_html =
          `<input class="form-control format-form-style" required="required" "type="text" value=""
          name="[question_attributes][${question_id}][${form_table_type_value}_attributes][${form_table_type_value}_option_strings_attributes][${option_index}][option_string]"
          id="_question_attributes_${question_id}_${form_table_type_value}_attributes_${form_table_type_value}_option_strings_attributes_${option_index}_option_string">`;
          return option_input_html;
        }

        // クリックされたボタンの親のを取得
        // thisは、クリックされたオブジェクト
        var option_add_btn_box = this.parentNode;
        console.log(option_add_btn_box)
        // クリックされたボタンの親の親を取得
        var option_form_edit = option_add_btn_box.parentNode;
        console.log(option_form_edit)
        // クリックされたボタンの親の親の最初の子を取得してクローン
        var clone_option_box = option_form_edit.firstElementChild.cloneNode(true);
        console.log(clone_option_box)
        // 差し替え用のinput要素を生成するのに必要な変数を定義(この変数達は関数であるbuildOptionTextField並びにbuildDestroyHiddenField内で使用)
        // クローンしたDMO内のdata-form-table-type-valueの値を取得
        var form_table_type_value = clone_option_box.dataset.formTableTypeValue;
        console.log(form_table_type_value)
        // クローンしたDMO内のclass属性の値がoption-boxの要素数を取得(インデックス値は0から始まるため取得値をそのまま使用)
        var option_index = option_form_edit.querySelectorAll("div[class='option-box']").length;
        console.log(option_index)
        // クローンしたDMO内のdata-question-idの値を取得
        var question_id = clone_option_box.dataset.questionId;
        console.log(question_id)
        // クローンしたDMOのtype属性が'hidden'のinput要素を取得
        var id_input_field = clone_option_box.querySelector("input[type='hidden']");
        console.log(id_input_field)
        // 取得したinput要素を生成した差し替え用のinput要素に変更
        id_input_field.outerHTML = buildIdHiddenField(form_table_type_value, option_index, question_id);
        // クローンしたDMOのtype属性が'text'のinput要素を取得
        var option_input_field = clone_option_box.querySelector("input[type='text']");
        console.log(option_input_field)
        // 取得したinput要素を生成した差し替え用のinput要素に変更
        option_input_field.outerHTML = buildOptionTextField(form_table_type_value, option_index, question_id);
        // data-form-indexの値を変更
        clone_option_box.dataset.formIndex = `${option_index}`;
        // 追加する要素を最終確認
        console.log(clone_option_box)
        // 編集したDOMを追加
        $(option_add_btn_box).before(clone_option_box);
        $(clone_option_box).closest('div').show()

        // 削除ボタンの表示を切り替え
        var option_form_edit = $(this).parent().parent();
        console.log(option_form_edit)
        var option_box = option_form_edit.children('.option-box').filter(':visible');
        console.log(option_box)
        option_box_count = option_box.length;
        console.log(option_box_count)
        if (option_box_count >= 2) {
          console.log(true)
          for (var i = option_box_count - 1; i >= 0; i--) {
            var a = option_box[i].querySelector("a[class='remove-field']").style.display = 'inline';
            console.log(a)
            // option_box[i].querySelector("a[class='remove-field']").visibility = 'visible';
          }
        }

        // フォームが持つデフォルトの動作をキャンセル
        event.preventDefault()
      });
    }
    // 削除ボタンが押された時option入力フィールドを削除する処理(name属性がcreateのinput要素のvalue値がによって処理を分岐)
    $('.option-form-edit').on('click', '.remove-field', function(event){
      // 押された削除ボタンのclass属性の値がoption-form-editの要素を取得
      var option_form_edit = $(this).parent().parent();
      console.log(option_form_edit)
      // 押された削除ボタンの全ての兄弟要素内でinput要素内のname属性の値にidを含む要素のvalue値を取得
      id_hidden_field_value = $(this).prevAll('input[name*=id]').val()
      console.log(id_hidden_field_value);
      if (id_hidden_field_value) {
        // 押された削除ボタンの前にある要素でinput要素内のname属性の値に_destroyを含む要素のalue値をtrueに
        $(this).prev('input[name*=_destroy]').val('true')
        // 押された削除ボタンの親のdiv要素を非表示
        $(this).closest('div').hide()
        event.preventDefault()
      } else {
        // 押された削除ボタンの親のdiv要素を削除
        $(this).closest('div').remove()
        event.preventDefault()
      }

      var option_box = option_form_edit.children('.option-box');
      console.log(option_box)
      option_box_count = option_box.filter(':visible').length;
      console.log(option_box_count)
      if (option_box_count <= 1) {
        option_box[0].querySelector("a[class='remove-field']").style.display = 'none';
      event.preventDefault()
      }
    });
  });

  // ドラッグアンドドロップに関する処理
  // .formを全て取得しeach処理でドラック＆ドロップに関するイベントを設定
  document.querySelectorAll('.form').forEach (element => {
    // dragstartは要素がドラッグされた時に発生するイベントで、このイベントに関数を代入
    element.ondragstart = function (event) {
      // eventをレシーバーにdataTransfer.setData()メソッドを呼び出す。
      // このメソッドはドラッグ操作の drag data に指定したデータと型を設定する。
      // 今回はデータの方に'text/plain'、データにevent.target.idを指定している。
      // これにより、.formのidの値をdrag objectに追加している。これは後の処理で取り出して使う。
      event.dataTransfer.setData('text/plain', event.target.id);
    };

    // ondragoverイベントとは、ドラッグ状態のマウスのポインタ（カーソル）が、ドロップ可能な要素上に重なってる時のイベントを設定する。
    element.ondragover = function (event) {
      // 「event.preventDefault()は、そのイベントのデフォルト処理をキャンセルするメソッドです。ondragoverイベントのデフォルト処理をキャンセルしないと、// ondropイベントが送出されない為に必須。
      event.preventDefault();
      // thisで重なった要素を取得し、style.borderTop = '3px solid'で要素の枠上の線を少し太くしている。
      this.style.borderTop = '3px solid';
    };

    element.ondragleave = function () {
    this.style.borderTop = "";
    };

    element.ondrop = function (event) {
      var position_num = 0
      event.preventDefault();
      let id = event.dataTransfer.getData('text');
      // console.log(id);
      let element_drag = document.getElementById(id);
      // console.log(element_drag);
      let element_drag_num = element_drag.querySelector("input[class='position']").value;
      // console.log(element_drag_num);
      // console.log(this);
      let this_num = (this).querySelector("input[class='position']").value;
      // console.log(this_num);
      if (element_drag_num < this_num) {
        this.parentNode.insertBefore(element_drag, this.nextSibling);
      } else {
        this.parentNode.insertBefore(element_drag, this);
      }
      this.style.borderTop = '';
      document.querySelectorAll('.position').forEach (element => {
        position_num = ++position_num;
        // console.log(position_num)
        element.value = position_num;
      });
    };
  });

  // ドラック有効、無効を切り替える処理
  $(function($) {
    // .dorack-areaにマウスポインタが触れている時.formをドラック出来る様にするよ
    // まず.dorack-areaを全て取得してeach処理するよ
    document.querySelectorAll('.dorack-area').forEach (element => {
      // eachで1つずつ取り出された要素はelementに入るよ
      // この要素にonmouseoverイベントを設定するよ
      element.onmouseover = function () {
        // console.log( "オンマウスオーバーイベントを感知しました(￣^￣)ゞ" )
        // .formを全て取得してeach処理するよ
        document.querySelectorAll('.form').forEach (element => {
          // 取り出した要素のdraggable属性をtrueに変更するよ
          // これで.dorack-areaにマウスポインタが触れた時にドラック出来る様になるよ
          element.setAttribute( "draggable", "true");
          // console.log(element)
        });
      };

      // 今度は.dorack-areaからマウスポインタが離れた時.formをドラック出来ない様にするよ
      // 処理の流れは上記と同じだね
      element.onmouseout = function () {
        // console.log( "オンマウスアウトイベントを感知しました(￣^￣)ゞ" )
        document.querySelectorAll('.form').forEach (element => {
          element.setAttribute( "draggable", "false");
          // console.log(element)
        });
      };
    });
  })
});

// console.log(true);
