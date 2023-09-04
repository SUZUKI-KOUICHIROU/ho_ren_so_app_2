class ProjectUser < ApplicationRecord
  belongs_to :user
  belongs_to :project

  # プロジェクトメンバーそれぞれに報告集計メンバーの除外ステータスを追加する
  def self.member_expulsion_join(project, members)
    project_member_expulsions = project.project_users.all
    members.each do |member|
      member.member_expulsion = project_member_expulsions.find_by(user_id: member.id).member_expulsion
    end
    return members
  end
end
