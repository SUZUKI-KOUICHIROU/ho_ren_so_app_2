require 'rails_helper'

RSpec.describe "Projects::Members", type: :request do
  describe "GET /users/:user_id/projects/:project_id/index" do
    context "メンバー一覧にログイン中ユーザーがアクセスした場合" do
      before do
        @user = FactoryBot.create(:unique_user)
        sign_in @user
        @project = FactoryBot.create(:project)
        @user.projects << @project
        @project_user = FactoryBot.create(:project_user, user: @user, project: @project)

        get project_member_index_path(@user, @project)
      end

      it "HTTPリクエストが200 httpレスポンスを返す" do
        expect(response).to have_http_status(200)
      end

      it "プロジェクトメンバーの一覧が表示される" do
        expect(response.body).to include(@project_user.user.name)
      end

      it "検索ボックスが表示される" do
        expect(response.body).to include("検索")
      end

      it "報告頻度が取得される" do
        expect(assigns(:report_frequency)).to eq(@project.report_frequency)
      end

      it "プロジェクトユーザーが取得される" do
        expect(assigns(:project_user)).to eq(@project_user)
      end
    end

    context "ログインしていない場合" do
      it "ログインページにリダイレクトされる" do
        get project_member_index_path(1, 1)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
