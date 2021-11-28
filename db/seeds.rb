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
project_leader_id = 1
project_report_frequency =1
project_next_report_date = Date.current.since(project_report_frequency.days)
project_reported_flag = false
Project.create!( project_name: project_name,
                 project_leader_id: project_leader_id,
                 project_report_frequency: project_report_frequency,
                 project_next_report_date: project_next_report_date,
                 project_reported_flag: project_reported_flag )

project_name = '新規ユーザーを10人獲得'
project_leader_id = 1
project_report_frequency =1
project_next_report_date = Date.current.since(project_report_frequency.days)
project_reported_flag = false
Project.create!( project_name: project_name,
                 project_leader_id: project_leader_id,
                 project_report_frequency: project_report_frequency,
                 project_next_report_date: project_next_report_date,
                 project_reported_flag: project_reported_flag )

# 全ユーザーを全てのプロジェクトに参画
users = User.all
projects = Project.all
users.each do |user|
  projects.each do |project|
    user.projects << project
  end
end

# 報告フォーマット作成
projects = Project.all
projects.each do |project|
  # label_nameが件名のtext_fieldを生成
  text_field = TextField.new(label_name: '件名')
  text_field.build_form_display_order(position: 1,
                                      form_table_type: text_field.field_type,
                                      project_id: project.id)
  text_field.save

  # label_nameが報告内容のtext_areaを生成
  text_area = TextArea.new(label_name: '報告内容')
  text_area.build_form_display_order(position: 2,
                                    form_table_type: text_area.field_type,
                                    project_id: project.id)
  text_area.save

  # label_nameが発生している問題のradio_buttonを生成
  radio_button = RadioButton.new(label_name: '発生している問題')
  radio_button.build_form_display_order(position: 3,
                                        form_table_type: radio_button.field_type,
                                        project_id: project.id)
  radio_button.save
  radio_button.radio_button_option_strings.create!(option_string: 'あり')
  radio_button.radio_button_option_strings.create!(option_string: 'なし')

  # label_nameが問題内容のtext_areaを生成
  text_area = TextArea.new(label_name: '問題内容')
  text_area.build_form_display_order(position: 4,
                                    form_table_type: text_area.field_type,
                                    project_id: project.id)
  text_area.save

  # 以下テスト用
  # label_nameがテストチェックボックスのcheck_boxを生成
  check_box = CheckBox.new(label_name: 'テストチェックボックス')
  check_box.build_form_display_order(position: 5,
                                        form_table_type: check_box.field_type,
                                        project_id: project.id)
  check_box.save
  check_box.check_box_option_strings.create!(option_string: 'チェック１')
  check_box.check_box_option_strings.create!(option_string: 'チェック２')

  # # label_nameがテストセレクトボックスのselect_boxを生成
  select_box = Select.new(label_name: 'テストセレクトボックス')
  select_box.build_form_display_order(position: 6,
                                        form_table_type: select_box.field_type,
                                        project_id: project.id)
  select_box.save
  select_box.select_option_strings.create!(option_string: 'セレクト１')
  select_box.select_option_strings.create!(option_string: 'セレクト２')
end
