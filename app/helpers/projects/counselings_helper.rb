module Projects::CounselingsHelper
  def embedded_svg(filename, options = {})
    # file = File.read(Rails.root.join('app', 'assets', 'images', filename))
    file = Rails.root.join('app', 'assets', 'images', filename).read
    doc = Nokogiri::HTML::DocumentFragment.parse file
    svg = doc.at_css 'svg'
    svg['class'] = options[:class] if options[:class].present?
    doc.to_html.html_safe
  end

  # タブごとのページ設定
  def counseling_page(tab)
    page = {
      'you-addressee' => 'you_addressee_counselings_page',
      'counseling' => 'counselings_page'
    }
    page[tab]
  end
end
