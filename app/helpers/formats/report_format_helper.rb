module Formats::ReportFormatHelper
  # 追加ボタン
  # def link_to_add_field(name:, ftf:, form_option_symbol:, options:)
  #   # association で渡されたシンボルから、対象のモデルを作る
  #   # 前回コントローラーで実装したモデルの build にあたる処理
  #   new_object = ftf.object.class.reflect_on_association(form_option_symbol).klass.new

  #   # Javascript 側で配列のインデックス値とする
  #   # 追加しまくると、インデックス値がかぶりまくるので、
  #   # 後に Javascript 側でこのインデックス値は現在時刻をミリ秒にした値で置き換えていく
  #   id = new_object.object_id

  #   # f はビューから渡されたフォームオブジェクト
  #   # fields_for で f の子要素を作る
  #   fields = ftf.fields_for(form_option_symbol, new_object, child_index: id) do |_builder|
  #     render('option_form', ftf: ftf)
  #   end
  #   # ボタンの設置。classを指定してJavascriptと連動、fields を渡しておいて、
  #   # ボタン押下時にこの要素(fields)をJavascript側で増やすようにする
  #   link_to(name, '#', class: 'new-add-field btn btn-primary btn-sm', data: { id: id, fields: fields.delete("\n") })

  #   # Rails3系だと下記のように書けるが、4系で link_to_function は葬られた
  #   # link_to_function(name, raw("add_field(this, \"#{association}\", \"#{escape_javascript(fields)}\")"), options)
  # end

  # 削除ボタン
  # def link_to_remove_field(name:, osf:, options:)
  #   # _destroy の hiddenフィールドと削除ボタンを設置
  #   osf.hidden_field(:_destroy, class: 'destroy-flag') + link_to(name, '#', class: 'new-remove-field edit-remove-field')
  # end
end
