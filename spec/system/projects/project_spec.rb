# require 'rails_helper'

# RSpec.describe 'Projects', type: :system do

#   describe 'プロジェクト一覧' do
#     describe '表示のテスト' do
#       context 'プロジェクトリーダーの場合' do
#         let!(:user) { FactoryBot.create(:user, :user_with_projects) }
#         let!(:project) { user.projects.first }
#         let!(:user_2) { FactoryBot.create(:user, :user_2) }
#         before do
#           sign_in user
#           visit user_projects_path user
#         end
#         it '検索ボタンが表示されていること' do
#           expect(page).to have_button '検索'
#         end
#         it 'プロジェクト名が表示されていること' do
#           expect(page).to have_link 'プロジェクトA'
#         end
#         it 'プロジェクト毎に編集ボタンが表示されていること' do
#           expect(page).to have_link '編集'
#         end
#         it '次回報告日、報告または未報告が表示されていること' do
#           expect(page).to have_content '2023年04月20日(木)'
#           expect(page).to have_link '未報告'
#         end
#         it 'お知らせ表示がある場合、表示されていること' do
#           sign_in user_2
#           project.users << user_2
#           visit new_user_project_message_path(user_2, project)
#           check 'ユーザー1'
#           fill_in 'message_title', with: '連絡テスト'
#           fill_in 'message_message_detail', with: 'テスト'
#           click_button '送信'
#           visit new_user_project_counseling_path(user_2, project)
#           check 'ユーザー1'
#           fill_in 'counseling_title', with: '相談テスト'
#           fill_in 'counseling_counseling_detail', with: 'テスト'
#           click_button '送信'
#           sign_in user
#           visit user_projects_path user
#           expect(page).to have_link '新着の連絡'
#           expect(page).to have_content 'が1件あります。'
#           expect(page).to have_link '新着の相談'
#           expect(page).to have_content 'が1件あります。'
#         end
#         it 'お知らせがない場合、「無し」と表示されていること' do
#           expect(page).to have_content '無し'
#         end
#       end

#       context 'プロジェクトメンバーの場合' do
#         let!(:user) { FactoryBot.create(:user, :user_with_projects) }
#         let!(:project) { user.projects.first }
#         let!(:user_2) { FactoryBot.create(:user, :user_2) }
#         before do
#           sign_in user_2
#           project.users << user_2
#           visit user_projects_path user_2
#         end
#         it '検索ボタンが表示されていること' do
#           expect(page).to have_button '検索'
#         end
#         it 'プロジェクト名が表示されていること' do
#           expect(page).to have_link 'プロジェクトA'
#         end
#         it '編集ボタン非表示であること' do
#           expect(page).to have_link 'プロジェクトA'
#           expect(page).to have_no_link '編集'
#         end
#         it '次回報告日、報告または未報告が表示されていること' do
#           expect(page).to have_content '2023年04月20日(木)'
#           expect(page).to have_link '未報告'
#         end
#         it 'お知らせ表示がある場合、表示されていること' do
#           sign_in user
#           visit new_user_project_message_path(user, project)
#           check 'ユーザー2'
#           fill_in 'message_title', with: '連絡テスト'
#           fill_in 'message_message_detail', with: 'テスト'
#           click_button '送信'
#           visit new_user_project_counseling_path(user, project)
#           check 'ユーザー2'
#           fill_in 'counseling_title', with: '相談テスト'
#           fill_in 'counseling_counseling_detail', with: 'テスト'
#           click_button '送信'
#           sign_in user_2
#           visit user_projects_path user_2
#           expect(page).to have_link '新着の連絡'
#           expect(page).to have_content 'が1件あります。'
#           expect(page).to have_link '新着の相談'
#           expect(page).to have_content 'が1件あります。'
#         end
#         it 'お知らせがない場合、「無し」と表示されていること' do
#           expect(page).to have_content '無し'
#         end
#       end

#       context 'ログインユーザー（プロジェクト未参加）の場合' do
#         let!(:user) { FactoryBot.create(:user) }
#         it '参加しているプロジェクトがない場合' do
#           sign_in user
#           visit user_projects_path user
#           expect(page).to have_content '参画中のプロジェクトはありません。'
#         end
#       end
#     end

#     describe '検索機能のテスト' do
#       let!(:user) { FactoryBot.create(:user, :user_with_projects) }
#       let!(:project) { user.projects.first }
#       before do
#         sign_in user
#         visit user_projects_path user
#       end
#       it '入力したワードでヒットすること' do
#         fill_in 'プロジェクト名を入力', with: 'プロジェクトA'
#         click_button '検索'
#         expect(page).to have_link 'プロジェクトA'
#       end
#     end
#   end

#   describe 'プロジェクト詳細' do
#     let!(:user) { FactoryBot.create(:user, :user_with_projects) }
#     let!(:project) { user.projects.first }
#     let!(:user_2) { FactoryBot.create(:user, :user_2) }
#     context '表示のテスト' do
#       it 'プロジェクト名、概要、リーダー、報告頻度、メンバー数が表示されていること' do
#         sign_in user
#         visit user_project_path(user, project)
#         expect(page).to have_selector '.card-header', text: 'プロジェクトA'
#         expect(page).to have_selector '.card-text', text: '概要A'
#         expect(page).to have_selector '.card-text', text: 'ユーザー1'
#         expect(page).to have_selector '.card-text', text: '1日に１回'
#         expect(page).to have_selector '.card-text', text: 'メンバーはいません'
#       end
#       it 'リーダー交代のリクエストがある場合、重要なお知らせが表示されていること' do
#         project.users << user_2
#         sign_in user
#         visit project_member_index_path(user, project)
#           page.accept_confirm do
#             click_link 'リーダー権限を委譲'
#           end
#         visit user_projects_path user
#         sign_in user_2
#         visit user_project_path(user_2, project)
#         expect(page).to have_selector '.text-secondary', text: '重要なお知らせ'
#         expect(page).to have_selector '.card-text', text: 'リーダー交代のリクエストが来ています。'
#         expect(page).to have_link '受認'
#         expect(page).to have_link '辞退'
#       end
#     end
#   end

#   describe 'プロジェクト新規登録' do
#     let!(:user) { FactoryBot.create(:user) }
#     before do
#       sign_in user
#     end
#     context '表示のテスト' do
#       it '新規作成ボタンが表示されていること' do
#         visit new_user_project_path user
#         expect(page).to have_button '新規作成'
#       end
#       it '報告頻度「日数で設定」選択で報告回数欄が表示される' do
#         visit new_user_project_path user
#         number_field = find_by_id('report_frequency')
#         choose '日数で設定'
#         expect(page).to have_content '報告回数'
#         expect(number_field.value.to_i).to eq(1)
#         expect(page).to have_content '日に1回'
#       end
#       it '報告頻度「曜日で設定」選択で報告日欄が表示される' do
#         visit new_user_project_path user
#         choose '曜日で設定'
#         expect(page).to have_content '報告日'
#         expect(page).to have_content '毎週'
#         expect(page).to have_select('project[week_select]', selected: '月')
#         expect(page).to have_content '曜日'
#       end
#     end

#     context '登録のテスト' do
#       it '新規作成ボタン押下後、プロジェクト詳細ページに遷移し「プロジェクトを新規登録しました。」が表示されていること' do
#         visit new_user_project_path user
#         fill_in 'project_name', with: 'プロジェクトA'
#         fill_in 'project_description', with: '概要A'
#         choose '日数で設定'
#         fill_in 'report_frequency', with: 2
#         click_button '新規作成'
#         expect(page).to have_current_path user_project_path(user, user_id: user.id)
#         expect(page).to have_content 'プロジェクトを新規登録しました。'
#       end
#     end
#   end

#   describe 'プロジェクト編集' do
#     let!(:user) { FactoryBot.create(:user) }
#     before do
#       sign_in user
#       visit new_user_project_path user
#       fill_in 'project_name', with: 'プロジェクトA'
#       fill_in 'project_description', with: '概要A'
#       choose '日数で設定'
#       fill_in 'report_frequency', with: 2
#       click_button '新規作成'
#     end
#     context '表示のテスト' do
#       it '保存ボタンが表示されていること' do
#         visit edit_user_project_path(user, user_id: user.id)
#         expect(page).to have_button '保存'
#       end
#       it '削除ボタンが表示されていること' do
#         visit edit_user_project_path(user, user_id: user.id)
#         expect(page).to have_link '削除'
#       end
#       it '報告頻度「日数で設定」選択で報告回数欄が表示される' do
#         visit edit_user_project_path(user, user_id: user.id)
#         number_field = find_by_id('report_frequency')
#         choose '日数で設定'
#         expect(page).to have_content '報告回数'
#         expect(number_field.value.to_i).to eq(2)
#         expect(page).to have_content '日に1回'
#       end
#       it '報告頻度「曜日で設定」選択で報告日欄が表示される' do
#         visit edit_user_project_path(user, user_id: user.id)
#         choose '曜日で設定'
#         expect(page).to have_content '報告日'
#         expect(page).to have_content '毎週'
#         expect(page).to have_select('project[week_select]', selected: '')
#         expect(page).to have_content '曜日'
#       end
#     end

#     context '編集のテスト' do
#       it '保存ボタン押下後、プロジェクト詳細ページに遷移し「プロジェクトBの内容を更新しました。」が表示されていること' do
#         visit edit_user_project_path(user, user_id: user.id)
#         fill_in 'project_name', with: 'プロジェクトB'
#         fill_in 'project_description', with: '概要B'
#         choose '曜日で設定'
#         select '火', from: '報告日'
#         click_button '保存'
#         expect(page).to have_current_path user_project_path(user, user_id: user.id)
#         expect(page).to have_content 'プロジェクトBの内容を更新しました。'
#       end
#       it '削除ボタン押下→確認ダイアログOK押下後、プロジェクト一覧ページに遷移し「プロジェクトAを削除しました。」が表示されていること' do
#         visit edit_user_project_path(user, user_id: user.id)
#         page.accept_confirm do
#           click_link '削除'
#         end
#         expect(page).to have_current_path user_projects_path user
#         expect(page).to have_content 'プロジェクトAを削除しました。'
#       end
#       it '削除ボタン押下→確認ダイアログキャンセル押下後、編集ページのままであること' do
#         visit edit_user_project_path(user, user_id: user.id)
#         page.dismiss_confirm do
#           click_link '削除'
#         end
#         expect(page).to have_current_path edit_user_project_path(user, user_id: user.id)
#       end
#     end
#   end
# end
