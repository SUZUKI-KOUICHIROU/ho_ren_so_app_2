require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'userの登録' do
    context "nameカラム" do
      it "氏名が無ければ登録できない" do
      end

      it "氏名が20文字を超えると登録できない" do
      end
    end

    context "emailカラム" do
      it "メールアドレスが無ければ登録できない" do
      end

      it "メールアドレスが100文字を超えると登録できない" do
      end

      it "メールアドレスが正しいフォーマットでなければ登録できない" do
      end

      it "メールアドレスが重複していれば登録できない" do
      end
    end

    context "passwordカラム" do
      it "パスワードが無ければ登録できない" do
      end

      it "パスワードが8文字以上、30文字以内でなければ登録できない" do
      end

      it "パスワードが半角英数（英字は小文字のみ）でなければ登録できない" do
      end
    end

    context "password_confirmationカラム" do
      it "パスワード（確認用）が無ければ登録できない" do
      end

      it "パスワード（確認用）が8文字以上、30文字以内でなければ登録できない" do
      end
    end
  end
end
