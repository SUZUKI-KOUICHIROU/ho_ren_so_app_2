module MessageOperations
  extend ActiveSupport::Concern

  def save_message_and_send_to_members(message, _members)
    message_saved = message.save

    if message_saved
      if params[:message][:send_to_all]
        # TO ALLが選択されているとき
        @members.each do |member|
          @send = @message.message_confirmers.new(message_confirmer_id: member.id)
          @send.save
        end
      else
        # TO ALLが選択されていない時
        @message.send_to.each do |t|
          @send = @message.message_confirmers.new(message_confirmer_id: t)
          @send.save
        end
      end
    end

    message_saved
  end
end
