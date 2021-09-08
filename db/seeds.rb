# coding: utf-8
# 管理者を作成
User.create!( user_name: 'Admin User',
              email: 'admin@email.com',
              password: 'password',
              password_confirmation: 'password',
              admin: true )

# 一般ユーザーを5人作成
(0..4).each do |n|
  user_name = Faker::Name.name
  email = "sample#{n + 1}@email.com"
  password = 'password'
  User.create!( user_name: user_name,
                email: email,
                password: password,
                password_confirmation: password )
end

# プロジェクトを2件作成
project_name = '報連相アプリ開発'
project_leader_id = 2
project_report_frequency =1
project_next_report_date = Date.current.since(project_report_frequency.days)
project_reported_flag = false
Project.create!( project_name: project_name,
                 project_leader_id: project_leader_id,
                 project_report_frequency: project_report_frequency,
                 project_next_report_date: project_next_report_date,
                 project_reported_flag: project_reported_flag )

project_name = '新規ユーザーを10人獲得'
project_leader_id = 3
project_report_frequency =1
project_next_report_date = Date.current.since(project_report_frequency.days)
project_reported_flag = false
Project.create!( project_name: project_name,
                 project_leader_id: project_leader_id,
                 project_report_frequency: project_report_frequency,
                 project_next_report_date: project_next_report_date,
                 project_reported_flag: project_reported_flag )

# 全ユーザーをidが1のプロジェクトに参画
users = User.all
project = Project.find(1)
users.each do |user|
  user.projects << project
end
