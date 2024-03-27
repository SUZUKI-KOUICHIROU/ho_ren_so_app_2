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

    context '有効な報告時刻を指定した場合' do
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

    context '無効な報告時刻を指定した場合' do
      it 'report_timeが空の場合は報告時刻を設定できない' do
        invalid_report_time = nil # 無効な報告時刻の例
        expect { project_user.set_report_reminder_time(invalid_report_time) }.to raise_error(ArgumentError)
      end
    end
  end
end
