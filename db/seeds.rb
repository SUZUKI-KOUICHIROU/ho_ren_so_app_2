# coding: utf-8
########## 管理者を作成 ##########
User.create!( user_name: 'Admin User',
              email: 'admin@email.com',
              password: 'password',
              password_confirmation: 'password',
              admin: true )

########## 一般ユーザーを5人作成 ##########
(0..4).each do |n|
  user_name = Faker::Name.name
  email = "sample#{n + 1}@email.com"
  password = 'password'
  User.create!( user_name: user_name,
                email: email,
                password: password,
                password_confirmation: password )
end

########## プロジェクトを2件作成 ##########
Project.create!( project_name: 'プロジェクトA',
                 project_leader_id: 1,
                 project_report_frequency: 1,
                 project_next_report_date: Date.current.since(1.days),
                 description: 'テスト用に作成したプロジェクトAです。',
                 project_reported_flag: false )

Project.create!( project_name: 'プロジェクトB',
                 project_leader_id: 1,
                 project_report_frequency: 7,
                 project_next_report_date: Date.current.since(7.days),
                 description: 'テスト用に作成したプロジェクトBです。',
                 project_reported_flag: false )

########## idが1~3のユーザーをプロジェクトAに参画 ##########
users = User.where(id: [1, 2, 3, 4])
project = Project.find(1)
users.each do |user|
  user.projects << project
end

########## idが4~6のユーザーをプロジェクトBに参画 ##########
users = User.where(id: [1, 4, 5, 6])
project = Project.find(2)
users.each do |user|
  user.projects << project
end

########## 報告済/未済管理用レコードを作成 ##########
projects = Project.all
projects.each do |project|
  project.update_deadline(project.project_next_report_date)
end

########## プロジェクトAに報告フォーマットを登録 ##########
project = Project.find(1)
position_val = 1

# text_field
text_field = TextField.new( label_name: '件名' )
text_field.build_question( position: position_val,
                           form_table_type: text_field.field_type,
                           project_id: project.id )
text_field.save
position_val += 1

# text_field
text_field = TextField.new( label_name: 'コメント' )
text_field.build_question( position: position_val,
                           form_table_type: text_field.field_type,
                           project_id: project.id )
text_field.save
position_val += 1

# data_field
date_field = DateField.new( label_name: '期日' )
date_field.build_question( position: position_val,
                           form_table_type: date_field.field_type,
                           project_id: project.id )
date_field.save
position_val += 1

# data_field
date_field = DateField.new( label_name: '誕生日' )
date_field.build_question( position: position_val,
                           form_table_type: date_field.field_type,
                           project_id: project.id )
date_field.save
position_val += 1

# text_area
text_area = TextArea.new( label_name: '報告内容' )
text_area.build_question( position: position_val,
                          form_table_type: text_area.field_type,
                          project_id: project.id )
text_area.save
position_val += 1

# text_area
text_area = TextArea.new( label_name: '問題の内容' )
text_area.build_question( position: position_val,
                          form_table_type: text_area.field_type,
                          project_id: project.id )
text_area.save
position_val += 1

# radio_button
radio_button = RadioButton.new( label_name: '体調に問題はありますか？' )
radio_button.build_question( position: position_val,
                             form_table_type: radio_button.field_type,
                             project_id: project.id )
radio_button.save
radio_button.radio_button_option_strings.create!( option_string: 'あり' )
radio_button.radio_button_option_strings.create!( option_string: 'なし' )
position_val += 1

# radio_button
radio_button = RadioButton.new( label_name: '発生している問題' )
radio_button.build_question( position: position_val,
                             form_table_type: radio_button.field_type,
                             project_id: project.id )
radio_button.save
radio_button.radio_button_option_strings.create!( option_string: 'あり' )
radio_button.radio_button_option_strings.create!( option_string: 'なし' )
position_val += 1

# check_box
check_box = CheckBox.new( label_name: '担当している範囲はなんですか' )
check_box.build_question(position: position_val,
                                      form_table_type: check_box.field_type,
                                      project_id: project.id)
check_box.save
check_box.check_box_option_strings.create!( option_string: 'フロントエンド' )
check_box.check_box_option_strings.create!( option_string: 'バックエンド' )
position_val += 1

# check_box
check_box = CheckBox.new( label_name: '好きな食べ物はなんですか' )
check_box.build_question( position: position_val,
                          form_table_type: check_box.field_type,
                          project_id: project.id )
check_box.save
check_box.check_box_option_strings.create!( option_string: 'ラーメン' )
check_box.check_box_option_strings.create!( option_string: 'カレーライス' )
position_val += 1

# select_box
select_box = Select.new( label_name: '現在のお住まいの地域はどこですか' )
select_box.build_question( position: position_val,
                           form_table_type: select_box.field_type,
                           project_id: project.id )
select_box.save
select_box.select_option_strings.create!( option_string: '東日本' )
select_box.select_option_strings.create!( option_string: '西日本' )
position_val += 1

# select_box
select_box = Select.new( label_name: '体調が悪い場合、どんな問題がありますか？' )
select_box.build_question( position: position_val,
                           form_table_type: select_box.field_type,
                           project_id: project.id )
select_box.save
select_box.select_option_strings.create!( option_string: 'なし' )
select_box.select_option_strings.create!( option_string: '肉体的なもの（風邪など）' )
select_box.select_option_strings.create!( option_string: '精神的なもの（うつなど）' )
select_box.select_option_strings.create!( option_string: '両方' )

########## プロジェクトBに報告フォーマットを登録 ##########
project = Project.find(2)
position_val = 1

# text_field
text_field = TextField.new( label_name: '件名' )
text_field.build_question( position: position_val,
                           form_table_type: text_field.field_type,
                           project_id: project.id )
text_field.save
position_val += 1

# data_field
date_field = DateField.new( label_name: '期日' )
date_field.build_question( position: position_val,
                           form_table_type: date_field.field_type,
                           project_id: project.id )
date_field.save
position_val += 1

# text_area
text_area = TextArea.new( label_name: '報告内容' )
text_area.build_question( position: position_val,
                          form_table_type: text_area.field_type,
                          project_id: project.id )
text_area.save
position_val += 1

# radio_button
radio_button = RadioButton.new( label_name: '発生している問題' )
radio_button.build_question( position: position_val,
                             form_table_type: radio_button.field_type,
                             project_id: project.id )
radio_button.save
radio_button.radio_button_option_strings.create!( option_string: 'あり' )
radio_button.radio_button_option_strings.create!( option_string: 'なし' )
position_val += 1

# text_area
text_area = TextArea.new( label_name: '問題の内容' )
text_area.build_question( position: position_val,
                          form_table_type: text_area.field_type,
                          project_id: project.id )
text_area.save
position_val += 1

########## 報告済/未済管理用レコードを作成 ##########
projects = Project.all
projects.each do |project|
  project.update_deadline(project.project_next_report_date)
end
