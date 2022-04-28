namespace :notice_not_submitted_members do
	# タスクの説明
  desc "未報告者をリーダーに連絡する"
	task notice_not_submitted_members: :environment do
		targetDate = Date.yesterday
		Project.all.each do |project|
			if project.project_next_report_date == targetDate
				members = project.report_statuses.where(has_reminded: false, has_submitted: false, deadline: targetDate).pluck(:user_id)
				if members.count > 0
					leaderEmail = project.users.find(project.project_leader_id).email
					users = project.users.where(id: members).pluck(:user_name)
					UserMailer.notice_not_submitted_members(project.project_name,users,leaderEmail).deliver
				end
			end
		end
		puts 'notice not submitted members!'
	end
end
