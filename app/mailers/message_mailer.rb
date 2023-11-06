class MessageMailer < ApplicationMailer
  def send_email(recipient, importance, title, message_detail, sender_name)
    @importance = importance
    @recipient = recipient
    @title = title
    @message_detail = message_detail
    @sender_name = sender_name

    if @recipient.nil?
      # recipientがnilの場合のエラーハンドリングを行うか、処理を記述する
      # 例えば、ログにエラーメッセージを記録するなど
      Rails.logger.error("Recipient is nil for message with importance: #{@importance}")
    else
      mail(to: @recipient, subject: "重要度「#{@importance}」の連絡が来ています。")
    end
  end
end
