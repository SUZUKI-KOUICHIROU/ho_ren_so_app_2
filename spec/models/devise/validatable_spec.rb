require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validatableモジュールのテスト' do
    it '有効なメールアドレスとパスワードがあればバリデーションに通る' do
      user = build(:user)
      expect(user).to be_valid
    end

    it 'メールアドレスが無ければ無効' do
      user = build(:user, email: nil)
      expect(user).to be_invalid
    end

    it '不適切なメールアドレスは無効' do
      user = build(:user, email: "test@")
      expect(user).to be_invalid
    end

    it '6字未満パスワードは無効' do
      user = build(:user, password: "short")
      expect(user).to be_invalid
    end

    it '129字以上パスワードは無効' do
      long_password = "a" * 129
      user = build(:user, password: long_password)
      expect(user).to be_invalid
    end
  end
end
