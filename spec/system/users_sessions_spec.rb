require 'rails_helper'

RSpec.describe 'UsersSessions', type: :system do
  let!(:user) { create(:user) }

  describe 'ユーザーログインページ' do
    before do
      visit new_user_session_path
    end

    context 'ユーザーログインページの要素' do
      it 'ログインを記憶するチェックボックスがあること' do
        expect(page).to have_field 'user[remember_me]'
      end

      it 'パスワードを忘れた場合のリンクがあること' do
        expect(page).to have_link 'パスワードを忘れた場合'
      end

      it '新規登録ボタンがないこと' do
        expect(page).to have_no_link '新規登録'
      end

      it 'ログインボタンがあること' do
        expect(page).to have_button 'ログイン'
      end
    end

    context '画面遷移' do
      it 'パスワードを忘れた場合' do
        click_on 'パスワードを忘れた場合'
        expect(page).to have_current_path new_user_password_path, ignore_query: true
        expect(page).to have_content 'パスワード再設定'
      end
    end

    context 'ログイン処理' do
      it 'email、passwordが正常な値の場合ログインに成功すること' do
        expect do
          fill_in 'session[email]', with: user.email.to_s
          fill_in 'session[password]', with: user.password.to_s
          check 'parent[remember_me]'
          click_button 'ログイン'
          expect(page).to have_current_path user_path user, ignore_query: true
          expect(page).to have_content 'ログイン情報'
        end
      end

      it 'emailが不正な値の場合ログインに失敗すること' do
        expect do
          fill_in 'session[email]', with: 'q'
          fill_in 'session[password]', with: parent.password.to_s
          click_on 'ログイン'
          expect(page).to have_current_path login_path, ignore_query: true
          expect(page).to have_content 'メールアドレスまたはパスワードが違います。'
        end
      end

      it 'passwordが不正な値の場合ログインに失敗すること' do
        expect do
          fill_in 'session[email]', with: parent.email.to_s
          fill_in 'session[password]', with: 'q'
          click_on 'ログイン'
          expect(page).to have_current_path login_path, ignore_query: true
          expect(page).to have_content 'メールアドレスまたはパスワードが違います。'
        end
      end
    end
  end
end
