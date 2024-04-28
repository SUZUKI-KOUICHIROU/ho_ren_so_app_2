require 'rails_helper'

RSpec.describe "Projects::Members", type: :request do
  describe "GET /users/:user_id/projects/:project_id/index" do
    context "プロジェクトメンバーがメンバー一覧にアクセスした場合" do
      let(:user) { FactoryBot.create(:unique_user) }
      let(:project) { FactoryBot.create(:project) }
      let!(:project_user) { FactoryBot.create(:project_user, user: user, project: project) }
      before do
        sign_in user # Deviseでログインさせる事を前提として設定
      end

      subject { get project_member_index_path(user, project) } # テスト対象のコードを実行

      it "HTTPリクエストに対し200レスポンスを返す" do
        subject
        expect(response).to have_http_status(200)
      end

      it "プロジェクトメンバーの一覧が表示される" do
        subject
        expect(response.body).to include(project_user.user.name)
      end

      it "検索ボックスが表示される" do
        subject
        expect(response.body).to include("検索")
      end

      it "リーダー権限の委譲が取得される" do
        subject
        expect(assigns(:delegates)).to eq(project.delegations)
      end

      it "報告頻度が取得される" do
        subject
        expect(assigns(:report_frequency)).to eq(project.report_frequency)
      end

      it "プロジェクトユーザーが取得される" do
        subject
        expect(assigns(:project_user)).to eq(project_user)
      end

      context "検索ボックスで検索した場合" do
        let(:search_keyword) { "テスト" }

        it "検索キーワードにマッチするメンバーのみ表示される" do
          matching_user = FactoryBot.create(:unique_user, name: "テストユーザー")
          FactoryBot.create(:project_user, user: matching_user, project: project)
          # 検索リクエストを送信
          get project_member_index_path(user, project), params: { search: search_keyword }
          # 検索キーワードにマッチするか確認
          expect(response.body).to include(matching_user.name)
        end
      end

      context "ページネーションを含む場合" do
        let!(:members) { create_list(:unique_user, 14) } # 14人のユーザーを追加作成
        let!(:project_users) { members.map { |member| create(:project_user, user: member, project: project) } } # それぞれをプロジェクトに加入させる

        it "1ページ目には10人のメンバーが表示される" do
          get project_member_index_path(user, project), params: { page: 1 }

          expect(assigns(:members).count).to eq(10)
        end

        it "2ページ目には残りの5人のメンバーが表示される" do
          get project_member_index_path(user, project), params: { page: 2 }

          expect(assigns(:members).count).to eq(5)
        end
      end
    end
  end
end
