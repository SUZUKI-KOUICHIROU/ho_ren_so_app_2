class MessageMailer < ApplicationMailer
  def send_email(recipient, importance)
    @importance = importance
    @recipient = recipient

    if @recipient.nil?
      # recipientがnilの場合のエラーハンドリングを行うか、処理を記述する
      # 例えば、ログにエラーメッセージを記録するなど
      Rails.logger.error("Recipient is nil for message with importance: #{@importance}")
    else
      mail(to: @recipient, subject: "重要度「#{@importance}」の連絡が来ています。")
    end
  end
end
