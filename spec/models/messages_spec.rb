require 'rails_helper'

RSpec.describe Message, type: :model do
  subject(:message) { FactoryBot.build(:message) }

  describe 'messageの登録' do
    context '連絡の投稿' do
      before(:each) do
        # テスト用のプロジェクトを作成し、インスタンス変数に格納
        @project = create(:project)
      end
      it '送信相手、件名、連絡内容、重要度があれば登録できる' do
        expect(build(:message, title: 'test', message_detail: 'test', send_to_all: true, importance: '低')).to be_valid
      end
      it 'titleがなければ投稿できない' do
        expect(build(:message, title: '')).to be_invalid
      end
      it '件名が31文字以上は投稿できない' do
        expect(build(:message, title: 'a' * 31)).to be_invalid
      end
      it '連絡内容がなければ投稿できない' do
        expect(build(:message, message_detail: '')).to be_invalid
      end
      it '501文字以上は投稿できない' do
        expect(build(:message, message_detail: 'a' * 501)).to be_invalid
      end
    end

    context '送信相手' do
      it '送信相手が空な場合は投稿できない' do
        expect(build(:message, send_to_all: 'false' && :message, send_to: '')).to be_invalid
      end
    end

    context '送信相手' do
      it '送信相手が空な場合は投稿できない' do
        expect(build(:message, send_to_all: 'false' && :message, send_to: '')).to be_invalid
      end
    end
  end

  describe '重要度を設定' do
    before(:each) do
      # テスト用のプロジェクトを作成し、インスタンス変数に格納
      @project = create(:project)
    end
    context '重要度「中」か「高」である場合' do
      # it 'メールを送信できる' do
      #   recipients = ['recipient1@example.com', 'recipient2@example.com']
      #   message.set_importance('中', recipients)
      #   allow(MessageMailer).to receive(:send_email)
      #   expect(MessageMailer).to have_received(:send_email).with(recipients, message.title,
      #  message.message_detail,
      #  message.sender_name, { importance: '中' }).once
      #   expect(build(:message, title: 'test', message_detail: 'test', send_to_all: true, importance: '低')).to be_valid
      #   expect(MessageMailer).to have_received(:send_email).with(recipients, message.title,
      #  message.message_detail,
      #  message.sender_name, {importance: '中'})
      # end

      it '重要度が「高」の場合は Slack で通知する' do
        allow(message).to receive(:send_slack_notification)
        message.set_importance('高', [])
        expect(message).to have_received(:send_slack_notification).with(message.title, message.message_detail).once
      end
    end

    context '重要度「中」か「高」ではない場合"' do
      it 'メールは送信できない' do
        recipients = ['recipient1@example.com', 'recipient2@example.com']
        message.set_importance('低', recipients)
        allow(MessageMailer).to receive(:send_email)
        expect(MessageMailer).not_to have_received(:send_email)
      end
      it '重要度が「高」ではない場合 Slack の通知はできない' do
        allow(message).to receive(:send_slack_notification)
        message.set_importance('低', [])
        expect(message).not_to have_received(:send_slack_notification)
      end
    end
  end

  describe '連絡検索' do
    let(:search_params) { { created_at: '2023-01-01', keywords: 'example' } }
    it '検索が空で実行された場合、全連絡を表示する' do
      expect(Message.search({})).to eq(Message.all)
    end
    it '検索した日付があれば検索した日付を表示する' do
      expect(Message).to receive(:created_at).with(search_params[:created_at]).and_call_original
      Message.search(search_params)
    end
    it '検索したキーワードを含むキーワードがあれば、検索キーワードが入った連絡を表示する' do
      expect(Message).to receive(:keywords_like).with(search_params[:keywords]).and_call_original
      Message.search(search_params)
    end
  end
end
