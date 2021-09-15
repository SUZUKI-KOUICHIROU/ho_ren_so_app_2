require 'rails_helper'

RSpec.describe 'UsersRegistrationsNews', type: :system do
  let!(:user) { create(:user) }

  before do
    sign_in user
    visit new_user_registration_path
  end

  context '新規登録ページの要素' do
    it '新規作成ボタンがあること' do
      expect(page).to have_button '新規作成'
    end
  end

  context '新規登録処理' do
    it '全ての値が正常な場合、登録内容確認ページに遷移すること' do
      fill_in 'user_name', with: 'サンプル'
      fill_in 'user_email', with: 'sample@email.com'
      fill_in 'user_password', with: '111111111'
      fill_in 'user_password_confirmation', with: '111111111'
      click_button '新規作成'
    end
  end

  context '新規登録失敗' do
    it '不正な値がある場合、新規登録にページ遷移すること' do
      fill_in 'user_name', with: ''
      fill_in 'user_email', with: 'sample@email.com'
      fill_in 'user_password', with: '111111111'
      fill_in 'user_password_confirmation', with: '111111111'
      click_button '新規作成'
      expect(page).to have_current_path new_user_registration_path, ignore_query: true
    end
  end
end
