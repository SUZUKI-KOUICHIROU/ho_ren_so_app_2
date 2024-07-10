require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'registerableモジュールのテスト' do
    describe 'バリデーションのテスト' do
      subject { FactoryBot.build(:user) }

      context 'データが有効である場合' do
        it 'バリデーションに通る' do
          expect(subject).to be_valid
        end
      end

      context 'メールアドレスがない場合' do
        it 'メールアドレスが無ければ無効' do
          subject.email = nil
          expect(subject).to be_invalid
        end
      end

      context 'メールアドレスが一意でない場合' do
        before { FactoryBot.create(:user, email: subject.email) }
        it '同じメールアドレスが既に存在する場合は無効' do
          expect(subject).to be_invalid
        end
      end

      context 'メールアドレスのフォーマットが不適切な場合' do
        it '不適切なフォーマットは無効' do
          invalid_emails = %w[user@foo,com user_at_foo.org example.user@foo.]
          invalid_emails.each do |invalid_email|
            subject.email = invalid_email
            expect(subject).to be_invalid
          end
        end
      end

      context 'パスワードが短すぎる場合' do
        it '短いパスワードは無効' do
          subject.password = 'short'
          expect(subject).to be_invalid
        end
      end
    end
  end

  describe 'recoverableモジュールのテスト' do
    let(:user) { create(:user) } # FactoryBotを使ってユーザーインスタンスを生成

    it 'パスワードリセットが要求されるとリセットトークンが生成されること' do
      user.send_reset_password_instructions # パスワードリセット指示の送信
      expect(user.reload.reset_password_sent_at).not_to be_nil # リセット指示前のトークンの存在確認
      expect(user.reset_password_period_valid?).to be true # リセット指示後のトークンの存在確認
    end

    it 'パスワードリセットトークンの有効期限を設定' do
      user.send_reset_password_instructions # パスワードリセット指示の送信
      expect(user.reload.reset_password_sent_at).not_to be_nil # パスワードリセットトークンの送信時刻が正しく記録されていることの確認
      expect(user.reset_password_period_valid?).to be true # トークンがまだ有効であること（期限切れでないこと）の確認
    end

    it '有効期限を過ぎるとトークンが無効になる' do
      user.send_reset_password_instructions # パスワードリセット指示の送信
      # 仮にトークンの有効期限を6時間後とする
      travel_to 7.hours.from_now do # 時刻を現在時刻から4時間後に設定
        expect(user.reset_password_period_valid?).to be false # トークンの有効期限が切れていることの確認
      end
    end
  end
end
