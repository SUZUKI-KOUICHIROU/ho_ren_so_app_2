require 'rails_helper'

RSpec.describe 'Users::Projects', type: :request do
  let!(:user) { FactoryBot.create(:user) }

  describe 'プロジェクト一覧ページ' do
    context 'ログイン済ユーザーの場合' do
      before do
        sign_in user
      end

      it 'GET /indexリクエストが成功すること' do
        get user_projects_path user
        expect(response).to be_successful
        expect(response).to have_http_status '200'
      end

      it 'GET /newリクエストが成功すること', js: true do
        get new_user_project_path(user), xhr: true
        expect(response).to be_successful
        expect(response).to have_http_status '200'
      end
    end

    context '未ログインユーザーの場合' do
      it 'GET /indexリクエストでログインページにリダイレクトされること' do
        get user_projects_path user
        expect(response).to be_successful
        expect(response).to have_http_status '200'
      end

      it 'GET /newリクエストが失敗', js: true do
        get new_user_project_path(user), xhr: true
        expect(response).to be_successful
        expect(response).to have_http_status '200'
      end
    end
  end
end
