module MessageOperations
  extend ActiveSupport::Concern

  def save_message_and_send_to_members(message, members)
    message_saved = message.save

    if message_saved
      members.each do |member|
        send = message.message_confirmers.new(message_confirmer_id: member.id)
        send.save
      end
    end

    message_saved
  end
end
