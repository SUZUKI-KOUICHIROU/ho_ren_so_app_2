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
                                    'チェックボックス' => 'check_box', 'プルダウン' => 'select', '日付' => 'date_field' }


  # サイドバーのヘルパーメソッド
  def sidebar_link_item(name, path, options = {})
    class_name = 'menu'
    class_name << ' active' if current_page?(path)

    content_tag :div, class: class_name do
      link_to name, path, options
    end
  end
end
