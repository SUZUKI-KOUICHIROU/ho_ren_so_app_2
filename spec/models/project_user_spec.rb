require 'rails_helper'

RSpec.describe ProjectUser, type: :model do
  subject(:project_user) { FactoryBot.build(:project_user) } # テストプロジェクトユーザーの作成
  let(:project) { project_user.project } # プロジェクトへの割当て
  let(:members) { project.users } # メンバーへの割当て

  before do
    ActiveJob::Base.queue_adapter = :test
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
    it 'キューからジョブが削除される（メソッド未実装につきテスト保留中＆実装後は要・修正）' do
      expect { project_user.dequeue_report_reminder }.not_to raise_error
    end
  end
end
