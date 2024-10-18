module Projects::CounselingsHelper
  def embedded_svg(filename, options = {})
    # file = File.read(Rails.root.join('app', 'assets', 'images', filename))
    file = Rails.root.join('app', 'assets', 'images', filename).read
    doc = Nokogiri::HTML::DocumentFragment.parse file
    svg = doc.at_css 'svg'
    svg['class'] = options[:class] if options[:class].present?
    doc.to_html.html_safe
  end

  # 相談の送信対象者を取得
  def get_counseling_recipients(counseling_id, members)
    recipients = CounselingConfirmer.where(counseling_id: counseling_id)
    recipient_names = []

    recipients.each do |recipient|
      member = members.find { |a| a[:id] == recipient.counseling_confirmer_id }
      recipient_names.push(member.name) if !member.nil?
    end
    recipient_names.join(', ')
  end

  # タブごとのページ設定
  def counseling_page(tab)
    page = {
      'you-addressee' => 'you_addressee_counselings_page',
      'you-send' => 'you_send_counselings_page',
      'counseling' => 'counselings_page'
    }
    page[tab]
  end
end
