module Projects::MessagesHelper
  def embedded_svg(filename, options = {})
    # file = File.read(Rails.root.join('app', 'assets', 'images', filename))
    file = Rails.root.join('app', 'assets', 'images', filename).read
    doc = Nokogiri::HTML::DocumentFragment.parse file
    svg = doc.at_css 'svg'
    svg['class'] = options[:class] if options[:class].present?
    doc.to_html.html_safe
  end

  # 連絡の送信対象者を取得
  def get_message_recipients(message_id, members)
    recipients = MessageConfirmer.where(message_id: message_id)
    recipient_names = []

    recipients.each do |recipient|
      member = members.find { |a| a[:id] == recipient.message_confirmer_id }
      recipient_names.push(member.name) if !member.nil?
    end
    recipient_names.join(', ')
  end
end
