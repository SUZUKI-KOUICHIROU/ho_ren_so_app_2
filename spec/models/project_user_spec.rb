require 'rails_helper'

RSpec.describe ProjectUser, type: :model do
  before do
    # ActiveJobのキューアダプターをテスト用に設定
    ActiveJob::Base.queue_adapter = :test
  end

  describe 'member_expulsion_joinメソッドのテスト' do
    context 'メンバーを正しく除外した場合' do
      it '除外したメンバーには除外ステータスが割り当てられる' do
        # テストプロジェクトの作成
        project = FactoryBot.create(:project)
    
        # テストユーザーの作成
        member1 = FactoryBot.create(:unique_user)
        member2 = FactoryBot.create(:unique_user)
        
        # テストプロジェクトへのメンバー関連付け
        project_user1 = FactoryBot.create(:project_user, project: project, user: member1)
        project_user2 = FactoryBot.create(:project_user, project: project, user: member2)

        # 除外ステータスの設定
        project_user1.update(member_expulsion: true)
        project_user2.update(member_expulsion: false)
        
        # メンバー配列の作成
        members = [member1, member2]
        
        # member_expulsion_joinメソッドの呼び出し
        ProjectUser.member_expulsion_join(project, members)
  
        # 各メンバーの除外ステータスを再度取得して検証
        members.each(&:reload)
      
        # メンバーのmember_expulsionメソッドが正しい設定かを検証
        expect(members[0].member_expulsion).to eq(true)
        expect(members[1].member_expulsion).to eq(false)
    
      end
    end
  end

  describe 'set_report_reminder_timeメソッドのテスト' do
    let(:project_user) { FactoryBot.create(:project_user) }

    context 'リマインド時刻を選択した場合' do
      it '報告リマインダー時刻を正しく設定できる' do
        report_time = Time.zone.now.to_s # 文字列に変換
        project_user.set_report_reminder_time(report_time)
        expect(project_user.reload.report_reminder_time).to eq(report_time.in_time_zone('Asia/Tokyo'))
      end

      it 'プロジェクトユーザーを保存する' do
        report_time = Time.zone.now.to_s # 文字列に変換
        expect { project_user.set_report_reminder_time(report_time) }.to change { project_user.reload.report_reminder_time }.from(nil).to(report_time.in_time_zone('Asia/Tokyo'))
      end
    end

    context 'リマインド時刻を選択しなかった場合' do
      it 'report_timeが空の場合はリマインド時刻を設定できない' do
        invalid_report_time = nil # 空のリマインド時刻を設定
        expect { project_user.set_report_reminder_time(invalid_report_time) }.to raise_error(ArgumentError)
      end
    end
  end

  describe 'calculate_reminder_datetimeメソッドのテスト' do
    let(:project_user) { FactoryBot.create(:project_user) }
    let(:reminder_days) { 1 } # テスト選択日数を1（日前）に設定
    let(:report_time) { "09:00:00" } # テスト選択時刻を午前9時に設定
    let(:next_report_date) { Date.current + 1 } # テスト次回報告日を翌日に設定

    context '選択日数が正の整数の場合' do
      it '次回報告日から選択日数分を差し引いた日時が指定日時として設定される' do
        reminder_datetime = project_user.calculate_reminder_datetime(reminder_days, report_time, next_report_date)
        expect(reminder_datetime).to eq(Time.zone.local(next_report_date.year, next_report_date.month, next_report_date.day, 9, 0, 0) - 1.day)
      end
    end

    context '選択日数が0の場合' do
      it '次回報告日がそのまま指定日時として設定される' do
        reminder_datetime = project_user.calculate_reminder_datetime(0, report_time, next_report_date)
        expect(reminder_datetime).to eq(Time.zone.local(next_report_date.year, next_report_date.month, next_report_date.day, 9, 0, 0))
      end
    end
  end

  describe 'queue_report_reminderメソッドのテスト' do
    context '有効な報告リマインド日時を設定した場合' do
      it '報告リマインダーのジョブがキューに追加される' do
        # テスト用のプロジェクトとユーザーを作成
        project = FactoryBot.create(:project)
        user = FactoryBot.create(:unique_user)
        user.projects << project

        # リマインダーの設定（有効な時刻を指定）
        report_time = Time.zone.now.to_s
        reminder_days = 1
        report_frequency = 7

        # キューにジョブが追加される
        expect {
          project_user = project.project_users.find_by(user_id: user.id)
          project_user.queue_report_reminder(project.id, user.id, report_frequency, reminder_days, report_time)
        }.to change { ActiveJob::Base.queue_adapter.enqueued_jobs.size }.by_at_least(1) # キューに1つ以上追加されることを確認
      end
    end

    context '無効な報告リマインド日時を設定した場合' do
      it 'report_timeが空の場合はジョブがキュー追加されない' do
        # テスト用のプロジェクトとユーザーを作成
        project = FactoryBot.create(:project)
        user = FactoryBot.create(:unique_user)
        user.projects << project

        # リマインダーの設定（無効な時刻を指定）
        report_time = nil
        reminder_days = 1
        report_frequency = 7

        # キューにジョブが追加されない
        expect { 
          project_user = project.project_users.find_by(user_id: user.id)
          project_user.queue_report_reminder(project.id, user.id, report_frequency, reminder_days, report_time) 
        }.to raise_error(ArgumentError, /Invalid report time:/)
      end
    end
  end

  describe 'dequeue_report_reminderメソッドのテスト' do
    context 'キューから報告リマインダージョブを削除する場合' do
      it 'キューからジョブが削除される（メソッド未実装につきテスト保留中＆実装後は要・修正）' do
        project_user = FactoryBot.create(:project_user)

        # 未実装中メソッドを呼び出してもエラーを発生させない処理（実装後は要・修正）
        expect { project_user.dequeue_report_reminder }.not_to raise_error
      end
    end
  end
end
