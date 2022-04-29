namespace :update_deadline do
	# タスクの説明
	desc "報告期日を更新する処理"
	# タスクの名前
	task update_deadline: :environment do
		Project.all.each do |project|
			targetDate = Date.yesterday
			if project.project_next_report_date <= targetDate
				nextDeadline = targetDate + project.project_report_frequency
				project.update_deadline(nextDeadline)
				project.update(project_next_report_date: nextDeadline)
			end
		end
		puts 'Complete!'
	end
	
end
