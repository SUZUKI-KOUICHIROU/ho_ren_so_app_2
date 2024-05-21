require 'rails_helper'

RSpec.describe "Projects::Members", type: :request do
  describe "GET /users/:user_id/projects/:project_id/index", as: :json do
    context "プロジェクトメンバーがメンバー一覧にアクセスした場合" do
      let(:user) { FactoryBot.create(:unique_user) }
      let(:project) { FactoryBot.create(:project) }
      let!(:project_user) { FactoryBot.create(:project_user, user: user, project: project) }

      before do
        sign_in user # Deviseでログインさせる事を前提として設定
      end

      subject { get project_member_index_path(user, project), as: :json } # テスト対象のコードを実行

      it "HTTPリクエストに対し200レスポンスを返す" do
        subject
        expect(response).to have_http_status(200)
      end

      it "プロジェクトメンバーの一覧をJSON形式で返す" do
        subject
        json_response = JSON.parse(response.body)
        expect(json_response["members"].length).to eq(1)
      end

      it "プロジェクトユーザーのデータを正確に返す" do
        subject
        json_response = JSON.parse(response.body)
        expected_project_user = {
          'id' => project_user.id,
          'user_id' => project_user.user_id,
          'project_id' => project_user.project_id,
          'created_at' => project_user.created_at.as_json,
          'updated_at' => project_user.updated_at.as_json,
          'member_expulsion' => project_user.member_expulsion,
          'reminder_days' => project_user.reminder_days,
          'reminder_enabled' => project_user.reminder_enabled,
          'report_reminder_time' => project_user.report_reminder_time.as_json,
          'report_time' => project_user.report_time&.strftime('%H:%M:%S')
        }
        expect(json_response["project_user"]).to eq(expected_project_user)
      end

      it "検索ボックスが表示される" do
        subject
        json_response = JSON.parse(response.body)
        expect(json_response["search_box"]).to eq(true)
      end

      it "リーダー権限の委譲が取得される" do
        subject
        json_response = JSON.parse(response.body)
        expect(json_response["delegates"]).to eq(project.delegations)
      end

      it "報告頻度が取得される" do
        subject
        json_response = JSON.parse(response.body)
        expect(json_response["report_frequency"]).to eq(project.report_frequency)
      end

      it "プロジェクトユーザーが取得される" do
        subject
        json_response = JSON.parse(response.body)
        expect(json_response["project_user"]["id"]).to eq(project_user.id)
      end

      context "検索ボックスで検索した場合" do
        let(:search_keyword) { "テスト" }

        it "検索キーワードにマッチするメンバーを返す" do
          matching_user = FactoryBot.create(:unique_user, name: "テストユーザー")
          another_user = FactoryBot.create(:unique_user, name: "別のユーザー")
          FactoryBot.create(:project_user, user: matching_user, project: project)
          FactoryBot.create(:project_user, user: another_user, project: project)
          
          # 検索リクエストを送信
          get project_member_index_path(user, project), params: { search: search_keyword }, as: :json
          json_response = JSON.parse(response.body)
          
          # 検索結果が正しいかを確認
          expect(json_response["members"].length).to eq(1)
          expect(json_response["members"][0]["name"]).to eq(matching_user.name)
        end
      end

      context "ページネーションを含む場合" do
        let!(:members) { create_list(:unique_user, 14) } # 14人のユーザーを追加作成
        let!(:project_users) { members.map { |member| create(:project_user, user: member, project: project) } } # それぞれをプロジェクトに加入させる

        it "1ページ目には10人のメンバーを返す" do
          get project_member_index_path(user, project), params: { page: 1 }, as: :json

          json_response = JSON.parse(response.body)
          expect(json_response["members"].length).to eq(10)
        end

        it "2ページ目には残りの5人のメンバーを返す" do
          get project_member_index_path(user, project), params: { page: 2 }, as: :json

          json_response = JSON.parse(response.body)
          expect(json_response["members"].length).to eq(5)
        end
      end
    end
  end

  describe "POST /projects/members/send_reminder" do
    context "リマインドメール送信設定のリクエストが有効な場合" do
      let(:user) { FactoryBot.create(:unique_user) }
      let(:project) { FactoryBot.create(:project) }
      let(:project_user) { FactoryBot.create(:project_user, user: user, project: project) }
      let(:member_id) { project_user.user_id }
      let(:report_frequency) { 7 }
      let(:reminder_days) { 1 }
      let(:report_time) { "09:00:00" }

      before do
        sign_in user
      end

      subject do
        post '/projects/members/send_reminder', params: {
          user_id: user.id,
          project_id: project.id,
          member_id: member_id,
          report_frequency: report_frequency,
          reminder_days: reminder_days,
          report_time: report_time
        }, as: :json
      end

      it "リマインダーが設定される" do
        subject
        expect(project_user.reload.reminder_enabled).to eq(true)
        expect(project_user.reminder_days).to eq(reminder_days)
        expect(project_user.report_time.strftime('%H:%M:%S')).to eq(report_time)
      end

      it "成功200レスポンスを返す" do
        subject
        expect(response).to have_http_status(200)
      end

      it "成功JSONレスポンスを返す" do
        subject
        json_response = JSON.parse(response.body)
        expect(json_response["success"]).to eq(true)
      end
    end

    context "リマインドメール送信設定のリクエストが無効な場合" do
      let(:user) { FactoryBot.create(:unique_user) }
      let(:project) { FactoryBot.create(:project) }
      let(:project_user) { FactoryBot.create(:project_user, user: user, project: project) }
      let(:member_id) { project_user.user_id }

      before do
        sign_in user
        allow_any_instance_of(ProjectUser).to receive(:update!).and_raise(StandardError, "internal_server_error")
      end

      subject do
        post '/projects/members/send_reminder', params: {
          user_id: user.id,
          project_id: project.id,
          member_id: member_id,
          report_frequency: nil,
          reminder_days: nil,
          report_time: "09:00:00"
        }, as: :json
      end

      it "失敗500レスポンスを返す" do
        subject
        expect(response).to have_http_status(500)
      end

      it "失敗JSONレスポンスとinternal_server_errorエラーを返す" do
        subject
        json_response = JSON.parse(response.body)
        expect(json_response["success"]).to eq(false)
        expect(json_response["error"]).to eq("internal_server_error")
      end
    end
  end
end
