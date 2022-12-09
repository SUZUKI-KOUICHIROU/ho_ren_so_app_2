
# 名前空間
namespace :notice_unsbmitted_member do
	# タスクの説明
	desc "未報告者をリーダーに連絡する処理"
	task :notice_unsubmitted_members => :environment do
		targetDate = Date.yesterday
		Project.all.each do |project|
			if project.next_report_date == targetDate
				members = project.report_statuses.where(has_reminded: false, has_submitted: false, deadline: targetDate).pluck(:user_id)
				if members.count > 0
					leaderEmail = project.users.find(project.leader_id).email
					users = project.users.where(id: members).pluck(:user_name)
					UserMailer.notice_not_submitted_members(project.name,users,leaderEmail).deliver
				end
			end
		end
		puts 'notice unsubmitted member!'
	end
end
