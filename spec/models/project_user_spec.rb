require 'rails_helper'

RSpec.describe ProjectUser, type: :model do
  subject(:project_user) { FactoryBot.build(:project_user) } # テストプロジェクトユーザーの作成
  let(:project) { project_user.project } # プロジェクトへの割当て
  let(:members) { project.users } # メンバーへの割当て

  before do
    ActiveJob::Base.queue_adapter = :test
  end

  describe 'バリデーションのテスト（send_reminderアクション時）' do
    context '報告リマインドメール送信日時の登録' do
      it '選択日数と選択時刻が正しく存在する場合、登録に成功する' do
        project_user.reminder_days = project_user.project.report_frequency - 1
        project_user.report_time = Time.zone.now.strftime('%H:%M:%S')
        expect(project_user).to be_valid(:send_reminder)
      end
    end

    context 'reminder_days（報告リマインド選択日数）' do
      it 'nilの場合、登録できない' do
        project_user.reminder_days = nil
        expect(project_user).not_to be_valid(:send_reminder)
      end

      it '0未満の場合、登録できない' do
        project_user.reminder_days = -1
        expect(project_user).not_to be_valid(:send_reminder)
        expect(project_user.errors[:reminder_days]).to include("リマインド指定日が選択肢として無効です。")
      end

      it 'report_frequency（報告頻度）以上の場合、登録できない' do
        project_user.reminder_days = project_user.project.report_frequency
        expect(project_user).not_to be_valid(:send_reminder)
        expect(project_user.errors[:reminder_days]).to include("リマインド指定日が選択肢として無効です。")
      end
    end

    context 'report_time（報告リマインド選択時刻）' do
      it 'nilの場合、登録できない' do
        project_user.report_time = nil
        expect(project_user).not_to be_valid(:send_reminder)
      end
    end
  end

  describe 'member_expulsion_joinメソッドのテスト' do
    context 'メンバーを集計対象から除外した場合' do
      it '除外したメンバーには除外ステータスが割り当てられる' do
        project_user.update(member_expulsion: true)

        # SQL文でメンバーの除外ステータスを更新＆SQL実行
        sql = <<-SQL.squish
          UPDATE project_users
          SET member_expulsion = true
          WHERE project_id = #{project.id}
        SQL
        ActiveRecord::Base.connection.execute(sql)

        members.each(&:reload)

        # SQL文で除外ステータスをＤＢから直接確認
        expect(ProjectUser.find_by_sql(
          "SELECT member_expulsion FROM project_users WHERE project_id = #{project.id}"
        ).pluck(:member_expulsion)).to eq([true])
      end
    end

    context 'メンバーを集計対象へと戻した場合' do
      it '除外したメンバーから除外ステータスが外される' do
        project_user.update(member_expulsion: false)

        # SQL文でメンバーの除外ステータスを更新＆SQL実行
        sql = <<-SQL.squish
          UPDATE project_users
          SET member_expulsion = false
          WHERE project_id = #{project.id}
        SQL
        ActiveRecord::Base.connection.execute(sql)

        members.each(&:reload)

        # SQL文で除外ステータスをＤＢから直接確認
        expect(ProjectUser.find_by_sql(
          "SELECT member_expulsion FROM project_users WHERE project_id = #{project.id}"
        ).pluck(:member_expulsion)).to eq([false])
      end
    end
  end

  describe 'set_report_reminder_timeメソッドのテスト' do
    let(:report_time) { Time.zone.now.to_s }

    context 'リマインド時刻を選択した場合' do
      it '報告リマインダー時刻を正しく設定できる' do
        project_user.set_report_reminder_time(report_time)

        expect(project_user.report_reminder_time).to eq(report_time.in_time_zone('Asia/Tokyo'))
      end
    end

    context 'リマインド時刻を選択しなかった場合' do
      it 'report_timeが空の場合はリマインド時刻を設定できない' do
        expect { project_user.set_report_reminder_time(nil) }.to raise_error(ArgumentError)
      end
    end
  end

  describe 'calculate_reminder_datetimeメソッドのテスト' do
    let(:next_report_date) { Date.current + 1 }

    context '選択日数が正の整数の場合' do
      it '次回報告日から選択日数分を差し引いた日時が指定日時として設定される' do
        reminder_datetime = project_user.calculate_reminder_datetime(1, '09:00:00', next_report_date)
        expect(reminder_datetime).to eq(
          Time.zone.local(next_report_date.year, next_report_date.month, next_report_date.day, 9, 0, 0) - 1.day
        )
      end
    end

    context '選択日数が0の場合' do
      it '次回報告日がそのまま指定日時として設定される' do
        reminder_datetime = project_user.calculate_reminder_datetime(0, '09:00:00', next_report_date)
        expect(reminder_datetime).to eq(
          Time.zone.local(next_report_date.year, next_report_date.month, next_report_date.day, 9, 0, 0)
        )
      end
    end
  end

  describe 'queue_report_reminderメソッドのテスト' do
    let(:user) { FactoryBot.build(:unique_user) }
    let(:reminder_days) { 1 }
    let(:report_time) { Time.zone.now.to_s }
    let(:report_frequency) { 7 }

    context '有効な報告リマインド日時を設定した場合' do
      it '報告リマインダーのジョブがキューに追加される' do
        user.projects << project

        expect {
          project_user.queue_report_reminder(project.id, user.id, report_frequency, reminder_days, report_time)
        }.to change { ActiveJob::Base.queue_adapter.enqueued_jobs.size }.by_at_least(1)
      end
    end

    context '無効な報告リマインド日時を設定した場合' do
      it 'report_timeが空の場合はジョブがキュー追加されない' do
        expect {
          project_user.queue_report_reminder(project.id, user.id, report_frequency, reminder_days, nil)
        }.to raise_error(ArgumentError, /Invalid report time:/)
      end
    end
  end

  describe 'dequeue_report_reminderメソッドのテスト' do
    include DebugHelper
    let(:project_id) { 1 }
    let(:member_id) { 2 }
    let(:other_project_id)  { 7 }
    let(:other_member_id) { 8 }
    let(:scheduled_set) { Sidekiq::ScheduledSet.new } # Sidekiqでスケジュールされたジョブセット

    before do
      # リマインドのリセット処理では、Sidekiqのクラスメソッドを使用しているため、testアダプタでは検証できない。
      # そのため、キューアダプタをSidekiqに指定する。
      ActiveJob::Base.queue_adapter = :sidekiq

      # ジョブの初期化（全ジョブをクリア）
      scheduled_set.clear
    end

    it 'キューからジョブが削除される' do
      # ジョブの追加
      ReminderJob.set(wait_until: 1.hour.from_now).perform_later(project_id, member_id)             # ジョブ1
      ReminderJob.set(wait_until: 1.hour.from_now).perform_later(other_project_id, other_member_id) # ジョブ2
      # ジョブ追加後のジョブ一覧をコンソールに表示
      puts ">>> #{scheduled_set.size}個のジョブを追加"
      disp_job_info(scheduled_set)

      # ジョブ1の削除
      project_user.dequeue_report_reminder(project_id, member_id)
      # ジョブの数が2個⇨1個になることを確認
      expect(scheduled_set.size).to eq(1)
      # 対象ジョブ削除後のジョブ一覧をコンソールに表示
      puts ">>> 引数が[#{project_id},#{member_id}]のジョブを削除"
      disp_job_info(scheduled_set)

      # ジョブ2の削除
      project_user.dequeue_report_reminder(other_project_id, other_member_id)
      # ジョブの数が1個⇨0個になることを確認
      expect(scheduled_set.size).to eq(0)
      # 対象ジョブ削除後のジョブ一覧をコンソールに表示
      puts ">>> 引数が[#{other_project_id},#{other_member_id}]のジョブを削除"
      disp_job_info(scheduled_set)
    end
  end
end
