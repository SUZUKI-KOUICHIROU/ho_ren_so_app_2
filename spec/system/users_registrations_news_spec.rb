require 'rails_helper'

# RSpec.describe 'UsersRegistrationsNews', type: :system do
#   # let!(:user) { create(:user) }

#   # before do
#   #   sign_in user
#   # end

#   context '新規登録ページの要素' do
#     it '新規作成ボタンがあること' do
#       visit new_user_registration_path
#       expect(page).to have_button 'button_create-user'
#     end
#   end

#   context '新規登録処理' do
#     it '全ての値が正常な場合、プロジェクト一覧ページに遷移する' do
#       visit new_user_registration_path
#       fill_in "users_name", with: 'サンプル'
#       fill_in 'users_email', with: 'sample@email.com'
#       fill_in 'user_password', with: '111111111'
#       fill_in 'user_password_confirmation', with: '111111111'
#       click_button '新規作成'
#     end
#   end

#   context '新規登録失敗' do
#     it '不正な値がある場合、新規登録にページ遷移すること' do
#       visit new_user_registration_path
#       fill_in "users_name", with: ''
#       fill_in 'users_email', with: 'sample@email.com'
#       fill_in 'user_password', with: '111111111'
#       fill_in 'user_password_confirmation', with: '111111111'
#       click_button '新規作成'
#       expect(page).to have_content '名前を入力してください'
#       expect(current_path).to eq '/users'
#       # expect(page).to have_current_path new_user_registration_path, ignore_query: true
#     end
#   end
# end
