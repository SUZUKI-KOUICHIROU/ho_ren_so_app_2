require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'database_authenticatableモジュールのテスト' do
    let(:user) { FactoryBot.create(:user, password: 'password', password_confirmation: 'password') }

    it 'パスワードの暗号化と有効性のテスト' do
      expect(user.encrypted_password).to be_present
      expect(user.valid_password?('password')).to be true
      expect(user.valid_password?('passward')).to be false
    end
  end

  describe 'rememberableモジュールのテスト' do
    let(:user) { create(:user) }

    it '有効な記憶トークンを生成' do
      user.remember_me!
      expect(user.remember_created_at).not_to be_nil
      expect(user.remember_token).not_to be_nil
    end

    it '記憶トークンをクリアする' do
      user.remember_me!
      expect(user.remember_token).not_to be_nil
      user.forget_me!
      expect(user.remember_token).to be_nil
    end
  end
end
