require 'rails_helper'

describe User, type: :model  do
  describe '#create' do
    describe "【email】" do
      describe "・存在性" do
        it "emailがない場合は登録できないこと" do
          user = build(:user, email: "")
          user.valid?
          expect(user.errors[:email]).to include("を入力してください")
        end

        it "emailがある場合登録できる" do
          user = build(:user)
          expect(user).to be_valid
        end
      end

      describe "・一意性" do
        it "email重複でエラー" do
          user = create(:user, email: "sample@email.com")
          user2 = build(:user, email: "sample@email.com")
          expect(user2).to be_invalid
        end

        it "email重複しなければOK" do
          user = create(:user)
          user2 = build(:user, email: "test@email.com")
          expect(user2).to be_valid
        end
      end

      describe "・フォーマット" do
        it "指定されたformatに当てはまること/\A[^@\s]+@[^@\s]+\z/" do
          user = build(:user)
          expect(user).to be_valid
        end

        it "指定されたformatに当てはまらない" do
          user = build(:user, email: "sample-email.com")
          expect(user).to be_invalid
        end
      end
    end

    describe "【encrypted_password】" do
      describe "・存在性" do
        it "passwordが存在すること" do
          user = build(:user)
          expect(user).to be_valid
        end

        it "passwordがない場合は登録できないこと" do
          user = build(:user, password: "")
          user.valid?
          expect(user.errors[:password]).to include("を入力してください")
        end
      end

      describe "・文字数" do
        it "パスワードが5文字の場合はNG" do
          buf_pass = "1" * 5
          user = build(:user, password: buf_pass, password_confirmation: buf_pass)
          expect(user).to be_invalid
        end

        it "パスワードが6文字の場合はOK" do
          buf_pass = "1" * 6
          user = build(:user, password: buf_pass, password_confirmation: buf_pass)
          expect(user).to be_valid
        end

        it "パスワードが50文字の場合はOK" do
          buf_pass = "1" * 50
          user = build(:user, password: buf_pass, password_confirmation: buf_pass)
          expect(user).to be_valid
        end

        it "パスワードが51文字以上の場合はNG" do
          buf_pass = "1" * 51
          user = build(:user, password: buf_pass, password_confirmation: buf_pass)
          expect(user).to be_invalid
        end
      end
    end

    describe "【name】" do
      it "nameがない場合NG" do
        user = build(:user, name: "")
        user.valid?
        expect(user.errors[:name]).to include("を入力してください")
      end

      it "nameがあればOK" do
        user = build(:user, name: "サンプル")
        expect(user).to be_valid
      end
    end
   
    end
  end
end