module ApplicationHelper
  # ページごとにタイトルを返すメソッドと引数の定義
  def full_title(page_name = '')
    base_title = 'Ho_Ren_So_App' # 基本となるアプリケーション名を変数に代入
    if page_name.empty? # 引数を受け取っているか判定
      base_title # 引数page_nameが空文字の場合はbase_titleのみ返す
    else # 引数page_nameが空文字ではない場合
      "#{page_name} | #{base_title}" # 文字列を連結して返す
    end
  end

  class << self
    attr_accessor :weeks, :form_option
  end

  ApplicationHelper.weeks = %w[日 月 火 水 木 金 土]

  ApplicationHelper.form_option = { '記述式' => 'text_field', '段落式' => 'text_area', 'ラジオボタン' => 'radio_button',
                                    'チェックボックス(複数選択可)' => 'check_box', 'プルダウン' => 'select', '日付' => 'date_field' }

  # サイドバーのヘルパーメソッド
  def sidebar_link_item(name, path, options = {})
    class_name = 'menu'
    class_name << ' active' if current_page?(path)

    content_tag :div, class: class_name do
      link_to name, path, options
    end
  end

  # flashメッセージをdeviseに対応させるため追加
  def bootstrap_alert(key)
    case key
    when "alert"
      "danger"
    when "notice"
      "success"
    when "error"
      "danger"
    when "primary"
      "primary"
    when 'danger'
      'danger'
    when 'success'
      'success'
    end
  end

  # テキスト内のURLを自動的にリンクに変換する。また、改行を有効化する。
  def format_text(text)
    link_text = Rinku.auto_link(simple_format(text), :urls, 'target="_blank" rel="noopener noreferrer"')
    sanitize(link_text, tags: %w(a p br), attributes: %w(href target rel)) # サニタイズして必要なタグと属性を許可
  end

  def flash_message_displayed!
    session[:flash_message_displayed] = true # flash_messageが表示されている場合trueになる
  end

  def flash_message_displayed?
    session[:flash_message_displayed] # true or falseを保持しているが初期は定義していないためfalse
  end
end
