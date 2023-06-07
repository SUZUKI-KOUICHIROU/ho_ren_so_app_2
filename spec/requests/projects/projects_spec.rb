# require 'rails_helper'

# RSpec.describe 'Projects', type: :request do
#   describe "アクションテスト" do

#     describe 'index' do
#       let(:user) { FactoryBot.create(:user) }
#       context 'ログインユーザーの場合' do
#         it 'indexリクエストが成功すること' do
#           sign_in user
#           get user_projects_path user
#           expect(response).to have_http_status 200
#         end
#       end

#       context 'ログインユーザーでない場合' do
#         it 'sessions/newへリダイレクトし、「ログインもしくはアカウント登録してください。」が表示されていること' do
#           get user_projects_path user
#           expect(response).to redirect_to new_user_session_path
#           expect(flash[:alert]).to eq 'ログインもしくはアカウント登録してください。'
#         end
#       end
#     end

#     describe 'show' do
#       let(:user) { FactoryBot.create(:user, :user_with_projects) }
#       let(:user_2) { FactoryBot.create(:user, :user_2) }
#       let(:project) { user.projects.first }

#       context 'プロジェクトリーダーの場合' do
#         it 'showリクエストが成功すること' do
#           sign_in user
#           get user_project_path(user, project)
#           expect(response).to have_http_status 200
#         end
#       end

#       context 'プロジェクトメンバーの場合' do
#         it 'showリクエストが成功すること' do
#           sign_in user_2
#           project.users << user_2
#           get user_project_path(user_2, project)
#           expect(response).to have_http_status 200
#         end
#       end

#       context 'プロジェクトメンバーでない場合' do
#         let(:user_2) { FactoryBot.create(:user, :user_2) }
#         xit 'projects/indexへリダイレクトし、「参加していないプロジェクトは閲覧できません。」が表示されていること' do
#           sign_in user_2
#           get user_project_path(user_2, project)
#           expect(response).to redirect_to user_projects_path
#           expect(flash[:alert]).to eq '参加していないプロジェクトは閲覧できません。'
#         end
#       end

#       context 'ログインユーザーでない場合' do
#         xit 'sessions/newにリダイレクトし、「ログインもしくはアカウント登録してください。」が表示されていること'do
#           get user_project_path
#           expect(response).to redirect_to new_user_session_path
#           expect(flash[:alert]).to eq 'ログインもしくはアカウント登録してください。'
#         end
#       end
#     end

#     describe 'new' do
#       let(:user) { FactoryBot.create(:user) }
#       context 'ログインユーザーの場合' do
#         it 'newリクエストが成功すること' do
#           sign_in user
#           get new_user_project_path user
#           expect(response).to have_http_status 200
#         end
#       end
#       context 'ログインユーザーでない場合' do
#         it 'sessions/newにリダイレクトし、「ログインもしくはアカウント登録してください。」が表示されていること'do
#           get new_user_project_path user
#           expect(response).to redirect_to new_user_session_path
#           expect(flash[:alert]).to eq 'ログインもしくはアカウント登録してください。'
#         end
#       end
#     end

#     describe 'create' do
#       let(:user) { FactoryBot.create(:user) }
#       let(:project) { user.projects.first }
#       context 'ログインユーザーの場合' do
#         before do
#           sign_in user
#         end
#         it 'createリクエストは302リダイレクトとなること' do
#           post user_projects_path(user), params: { project: FactoryBot.attributes_for(:project) }
#           expect(response).to have_http_status 302
#         end
#         it 'プロジェクトが登録されること' do
#           expect do
#             post user_projects_path(user), params: { project: FactoryBot.attributes_for(:project) }
#           end.to change(Project, :count).by(1)
#         end
#         it 'projects/showにリダイレクトし、「プロジェクトを新規登録しました。」が表示されていること' do
#           post user_projects_path(user), params: { project: FactoryBot.attributes_for(:project) }
#           expect(response).to redirect_to user_project_path(user, project)
#           expect(flash[:success]).to eq 'プロジェクトを新規登録しました。'
#         end
#       end

#       context '無効な属性の場合' do
#         before do
#           sign_in user
#         end
#         it 'プロジェクト名がnilの場合、projects/indexにリダイレクトし「プロジェクト新規登録に失敗しました。」が表示されていること' do
#           post user_projects_path(user), params: { project: FactoryBot.attributes_for(:project, name: nil) }
#           get user_projects_path(user)
#           expect(flash[:danger]).to eq 'プロジェクト新規登録に失敗しました。'
#         end
#         it 'プロジェクト名が21文字以上の場合、projects/indexにリダイレクトし「プロジェクト新規登録に失敗しました。」が表示されていること' do
#           post user_projects_path(user), params: { project: FactoryBot.attributes_for(:project, name: 'あ' * 21) }
#           get user_projects_path(user)
#           expect(flash[:danger]).to eq 'プロジェクト新規登録に失敗しました。'
#         end
#         it '概要がnilの場合、projects/indexにリダイレクトし「プロジェクト新規登録に失敗しました。」が表示されていること' do
#           post user_projects_path(user), params: { project: FactoryBot.attributes_for(:project, description: nil) }
#           get user_projects_path(user)
#           expect(flash[:danger]).to eq 'プロジェクト新規登録に失敗しました。'
#         end
#         it '概要が201文字以上の場合、projects/indexにリダイレクトし「プロジェクト新規登録に失敗しました。」が表示されていること' do
#           post user_projects_path(user), params: { project: FactoryBot.attributes_for(:project, description: 'あ' * 201) }
#           get user_projects_path(user)
#           expect(flash[:danger]).to eq 'プロジェクト新規登録に失敗しました。'
#         end
#         it '報告回数・報告日がnilの場合、projects/indexにリダイレクトし「プロジェクト新規登録に失敗しました。」が表示されていること' do
#           post user_projects_path(user), params: { project: FactoryBot.attributes_for(:project, report_frequency: nil) }
#           get user_projects_path(user)
#           expect(flash[:danger]).to eq 'プロジェクト新規登録に失敗しました。'
#         end
#         it '次回報告日がnilの場合、projects/indexにリダイレクトし「プロジェクト新規登録に失敗しました。」が表示されていること' do
#           post user_projects_path(user), params: { project: FactoryBot.attributes_for(:project, next_report_date: nil) }
#           get user_projects_path(user)
#           expect(flash[:danger]).to eq 'プロジェクト新規登録に失敗しました。'
#         end
#         it 'leader_idがnilの場合、projects/indexにリダイレクトし「プロジェクト新規登録に失敗しました。」が表示されていること' do
#           post user_projects_path(user), params: { project: FactoryBot.attributes_for(:project, leader_id: nil) }
#           get user_projects_path(user)
#           expect(flash[:danger]).to eq 'プロジェクト新規登録に失敗しました。'
#         end
#       end

#       context 'ログインユーザーでない場合' do
#         it 'sessions/newにリダイレクトし、「ログインもしくはアカウント登録してください。」が表示されていること' do
#           post user_projects_path(user)
#           expect(response).to redirect_to new_user_session_path
#           expect(flash[:alert]).to eq 'ログインもしくはアカウント登録してください。'
#         end
#       end
#     end

#     describe 'edit' do
#       let(:user) { FactoryBot.create(:user, :user_with_projects) }
#       let(:user_2) { FactoryBot.create(:user, :user_2) }
#       let(:project) { user.projects.first }

#       context 'ユーザーがプロジェクトのリーダーである場合' do
#         before do
#           sign_in user
#           get edit_user_project_path(user, project), params: { id: project.id }
#         end
#         it 'editリクエストが成功すること' do
#           get edit_user_project_path(user, project)
#           expect(response).to have_http_status 200
#         end
#       end

#       context 'ユーザーがプロジェクトのリーダーでない場合' do
#         before do
#           sign_in user_2
#           project.users << user_2
#           get edit_user_project_path(user_2, project), params: { id: project.id }
#         end
#         it 'projects/showにリダイレクトし、「リーダーではない為、権限がありません。」が表示されていること' do
#           expect(response).to have_http_status(:redirect)
#           expect(response).to redirect_to(user_project_path(user_2, project))
#           expect(flash[:danger]).to eq 'リーダーではない為、権限がありません。'
#         end
#       end

#       context 'ログインユーザーでない場合' do
#         xit 'sessions/newにリダイレクトし、「ログインもしくはアカウント登録してください。」が表示されていること' do
#           get edit_user_project_path
#           expect(response).to redirect_to new_user_session_path
#           expect(flash[:alert]).to eq 'ログインもしくはアカウント登録してください。'
#         end
#       end
#     end

#     describe 'update' do
#       let(:user) { FactoryBot.create(:user, :user_with_projects) }
#       let(:project) { user.projects.first }
#       let(:user_2) { FactoryBot.create(:user, :user_2) }
#       context 'ユーザーがプロジェクトのリーダーである場合' do
#         before do
#           sign_in user
#         end
#         it 'updateリクエストは302リダイレクトとなること' do
#           patch user_project_path(user, project),  params: { project: { name: 'プロジェクトB' } }
#           expect(response).to have_http_status 302
#         end
#         it 'プロジェクトが更新されること' do
#           #weeks = %w[日 月 火 水 木 金 土]
#           #week = weeks[project.next_report_date.wday]
#           project.update(name: 'プロジェクトB', description: '概要B', report_frequency: 7, next_report_date: '2023-4-6')
#           expect(project.name).to eq 'プロジェクトB'
#           expect(project.description).to eq '概要B'
#           expect(project.report_frequency).to eq 7
#           expect(project.next_report_date.strftime('%Y年%-m月%d日')).to eq '2023年4月06日'
#           #expect(project.next_report_date.strftime("%Y年%-m月%d日(#{week})")).to eq '2023年4月06日'
#         end
#         it 'projects/showにリダイレクトし、「プロジェクトBの内容を更新しました。」が表示されていること' do
#           patch user_project_path(user, project),  params: { project: { name: 'プロジェクトB' } }
#           expect(response).to redirect_to user_project_path(user, project)
#           expect(flash[:success]).to eq 'プロジェクトBの内容を更新しました。'
#         end
#       end

#       context '無効な属性の場合' do
#         before do
#           sign_in user
#         end
#         it 'プロジェクト名がnilの場合、projects/indexにリダイレクトし「の更新は失敗しました。」が表示されていること' do
#           patch user_project_path(user, project), params: { project: FactoryBot.attributes_for(:project, name: nil) }
#           get user_projects_path(user)
#           expect(flash[:danger]).to eq 'の更新は失敗しました。'
#         end
#         it 'プロジェクト名が21文字以上の場合、projects/indexにリダイレクトし「あああああああああああああああああああああの更新は失敗しました。」が表示されていること' do
#           patch user_project_path(user, project), params: { project: FactoryBot.attributes_for(:project, name: 'あ' * 21) }
#           get user_projects_path(user)
#           expect(flash[:danger]).to eq 'あああああああああああああああああああああの更新は失敗しました。'
#         end
#         it '概要がnilの場合、projects/indexにリダイレクトし「プロジェクトAの更新は失敗しました。」が表示されていること' do
#           patch user_project_path(user, project), params: { project: FactoryBot.attributes_for(:project, description: nil) }
#           get user_projects_path(user)
#           expect(flash[:danger]).to eq 'プロジェクトAの更新は失敗しました。'
#         end
#         it '概要が201文字以上の場合、projects/indexにリダイレクトし「プロジェクトAの更新は失敗しました。」が表示されていること' do
#           patch user_project_path(user, project), params: { project: FactoryBot.attributes_for(:project, description: 'あ' * 201) }
#           get user_projects_path(user)
#           expect(flash[:danger]).to eq 'プロジェクトAの更新は失敗しました。'
#         end
#         it '報告回数・報告日がnilの場合、projects/indexにリダイレクトし「プロジェクトAの更新は失敗しました。」が表示されていること' do
#           patch user_project_path(user, project), params: { project: FactoryBot.attributes_for(:project, report_frequency: nil) }
#           get user_projects_path(user)
#           expect(flash[:danger]).to eq 'プロジェクトAの更新は失敗しました。'
#         end
#         it '次回報告日がnilの場合、projects/indexにリダイレクトし「プロジェクトAの更新は失敗しました。」が表示されていること' do
#           patch user_project_path(user, project), params: { project: FactoryBot.attributes_for(:project, next_report_date: nil) }
#           get user_projects_path(user)
#           expect(flash[:danger]).to eq 'プロジェクトAの更新は失敗しました。'
#         end
#         it 'leader_idがnilの場合、projects/indexにリダイレクトし「プロジェクトAの更新は失敗しました。」が表示されていること' do
#           patch user_project_path(user, project), params: { project: FactoryBot.attributes_for(:project, leader_id: nil) }
#           get user_projects_path(user)
#           expect(flash[:danger]).to eq 'プロジェクトAの更新は失敗しました。'
#         end
#       end

#       context 'ユーザーがプロジェクトのリーダーでない場合' do
#         before do
#           sign_in user_2
#           project.users << user_2
#           patch user_project_path(user_2, project), params: { project: { name: 'プロジェクトB' } }
#         end
#         it 'projects/showにリダイレクトし、「リーダーではない為、権限がありません。」が表示されていること' do
#           expect(response).to redirect_to user_project_path(user_2, project)
#           expect(flash[:danger]).to eq 'リーダーではない為、権限がありません。'
#         end
#       end
#     end

#     describe 'destroy' do
#       let!(:user) { FactoryBot.create(:user, :user_with_projects) }
#       let!(:project) { user.projects.first }
#       let(:user_2) { FactoryBot.create(:user, :user_2) }
#       before do
#         sign_in user
#       end
#       context 'ユーザーがプロジェクトのリーダーである場合' do
#         it 'プロジェクトが削除されること' do
#           expect do
#             delete user_project_path(user, project)
#           end.to change(Project, :count).by(-1)
#         end
#         it 'projects/indexにリダイレクトし、「プロジェクトAを削除しました。」が表示されていること' do
#           expect do
#             delete user_project_path(user, project)
#           end.to change(Project, :count).by(-1)
#           expect(response).to redirect_to user_projects_path user
#           expect(flash[:success]).to eq 'プロジェクトAを削除しました。'
#         end
#       end

#       context 'ユーザーがプロジェクトメンバーである場合' do
#         before do
#           sign_in user_2
#           project.users << user_2
#         end
#         it 'projects/showにリダイレクトすること' do
#           delete user_project_path(user_2, project)
#           expect(response).to redirect_to user_project_path(user_2, project)
#           expect(flash[:danger]).to eq 'リーダーではない為、権限がありません。'
#         end
#       end

#       context 'ユーザーがプロジェクトに参加していない場合' do
#         before do
#           sign_in user_2
#         end
#         xit 'projects/indexにリダイレクトすること' do
#           delete user_project_path(user_2, project)
#           expect(response).to redirect_to user_projects_path user_2
#           expect(flash[:danger]).to eq 'リーダーではない為、権限がありません。'
#         end
#       end
#     end

#     describe 'join' do
#       let(:user) { FactoryBot.create(:user) }
#       let(:project) { FactoryBot.create(:project) }
#       let(:token) { Join.create(user_id: user.id, project_id: project.id).token }
#       context 'ユーザーがまだプロジェクトのメンバーでない場合' do
#         it 'プロジェクトに参加できること' do
#           get join_path, params: { token: token }
#           expect(project.users).to include(user)
#           expect(response).to redirect_to(user_project_path(user, project))
#         end
#         it 'projects/showにリダイレクトすること' do
#           get join_path, params: { token: token }
#           expect(response).to redirect_to(user_project_path(user, project))
#         end
#         it 'フラッシュメッセージ「プロジェクトAに参加しました。」が表示されること' do
#           get join_path, params: { token: token }
#           expect(flash[:success]).to eq('プロジェクトAに参加しました。')
#         end
#       end

#       context 'ユーザーが既にプロジェクトのメンバーである場合' do
#         before { project.users << user }
#         it 'プロジェクトに参加できないこと' do
#           get join_path, params: { token: token }
#           expect(project.users.count).to eq(1)
#         end
#         it 'projects/showにリダイレクトすること' do
#           get join_path, params: { token: token }
#           expect(response).to redirect_to(user_project_path(user, project))
#         end
#         it 'フラッシュメッセージ「参加済みプロジェクトです。」が表示されること' do
#           get join_path, params: { token: token }
#           expect(flash[:success]).to eq('参加済みプロジェクトです。')
#         end
#       end
#     end

#     describe 'accept_request' do
#       let!(:user) { FactoryBot.create(:user, :user_with_projects) }
#       let!(:project) { user.projects.first }
#       let!(:user_2) { FactoryBot.create(:user, :user_2) }
#       let!(:delegation) { FactoryBot.create(:delegation, project: project, user_to: user_2) }
#       context 'リーダー権限委譲リクエスト受認' do
#         before do
#           sign_in user
#           params = { delegate_id: 1, user_id: user.id, to: user_2.id }
#           post delegate_leader_path(user, project, to: params[:to]), params: params
#           #expect(response).to redirect_to(project_member_index_path(user.id, project.id))
#           #expect(flash[:success]).to eq('ユーザー2さんに権限譲渡のリクエストを送信しました。')
#         end
#         it 'projects/showにリダイレクトすること' do
#           post accept_request_path(user_2, project, delegation), params: { user_id: user_2.id, project_id: project.id, delegate_id: delegation.id }
#           expect(project.reload.leader_id).to eq(user_2.id)
#           expect(delegation.reload.is_valid).to be_falsey
#           expect(response).to redirect_to(user_project_path(delegation, project))
#         end
#         it 'フラッシュメッセージ「あなたがリーダーになりました。」が表示されること' do
#           post accept_request_path(user_2, project, delegation), params: { user_id: user_2.id, project_id: project.id, delegate_id: delegation.id }
#           expect(flash[:success]).to eq('あなたがリーダーになりました。')
#         end
#       end
#     end

#     describe 'disown_request' do
#       let!(:user) { FactoryBot.create(:user, :user_with_projects) }
#       let!(:project) { user.projects.first }
#       let!(:user_2) { FactoryBot.create(:user, :user_2) }
#       let!(:delegation) { FactoryBot.create(:delegation, project: project, user_to: user_2) }
#       context 'リーダー権限委譲リクエスト辞退' do
#         before do
#           sign_in user
#           params = { delegate_id: 1, user_id: user.id, to: user_2.id }
#           post delegate_leader_path(user, project, to: params[:to]), params: params
#           #expect(response).to redirect_to(project_member_index_path(user.id, project.id))
#           #expect(flash[:success]).to eq('ユーザー2さんに権限譲渡のリクエストを送信しました。')
#         end
#         it 'projects/showにリダイレクトすること' do
#           post disown_request_path(user_2, project, delegation), params: { user_id: user_2.id, project_id: project.id, delegate_id: delegation.id }
#           expect(project.reload.leader_id).to eq(user.id)
#           expect(delegation.reload.is_valid).to be_falsey
#           expect(response).to redirect_to(user_project_path(delegation, project))
#         end
#         it 'フラッシュメッセージ「リーダー交代リクエストを辞退しました。」が表示されること' do
#           post disown_request_path(user_2, project, delegation), params: { user_id: user_2.id, project_id: project.id, delegate_id: delegation.id }
#           expect(flash[:success]).to eq('リーダー交代リクエストを辞退しました。')
#         end
#       end
#     end
#   end
# end
