require 'rails_helper'

RSpec.describe ProjectUser, type: :model do

  describe 'member_expulsion_joinメソッドのテスト' do
    context '各メンバーに正しく除外ステータスを割り当てる' do
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
end
