require 'rails_helper'

RSpec.describe ProjectUser, type: :model do

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

    context '有効なリマインド時刻を指定した場合' do
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

    context '無効なリマインド時刻を指定した場合' do
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
      it '選択日数分を差し引いた日時が指定日時として設定されること' do
        reminder_datetime = project_user.calculate_reminder_datetime(reminder_days, report_time, next_report_date)
        expect(reminder_datetime).to eq(Time.zone.local(next_report_date.year, next_report_date.month, next_report_date.day, 9, 0, 0) - 1.day)
      end
    end

    context '選択日数が0の場合' do
      it '指定日時がそのまま設定されること' do
        reminder_datetime = project_user.calculate_reminder_datetime(0, report_time, next_report_date)
        expect(reminder_datetime).to eq(Time.zone.local(next_report_date.year, next_report_date.month, next_report_date.day, 9, 0, 0))
      end
    end
  end
end
