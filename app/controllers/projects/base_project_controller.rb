class Projects::BaseProjectController < BaseController
  before_action :project_reader_user

  # デフォルト報告フォーマット作成アクション(projects/projects#create内で呼ばれる)
  def report_format_creation(project)
    text_field = TextField.new(label_name: '件名')
    text_field.build_form_display_order(position: 1,
                                        form_table_type: text_field.field_type,
                                        project_id: project.id)
    text_field.save

    text_area = TextArea.new(label_name: '報告内容')
    text_area.build_form_display_order(position: 2,
                                       form_table_type: text_area.field_type,
                                       project_id: project.id)
    text_area.save

    radio_button = RadioButton.new(label_name: '発生している問題')
    radio_button.build_form_display_order(position: 3,
                                          form_table_type: radio_button.field_type,
                                          project_id: project.id)
    radio_button.save
    radio_button.radio_button_option_strings.create!(option_string: 'あり')
    radio_button.radio_button_option_strings.create!(option_string: 'なし')

    text_area = TextArea.new(label_name: '問題内容')
    text_area.build_form_display_order(position: 4,
                                       form_table_type: text_area.field_type,
                                       project_id: project.id)
    text_area.save
  end

  private

  # ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓ before_action（権限関連） ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
  # プロジェクトリーダーを許可
  def project_reader_user
    @project = Project.find(params[:id])
    return if current_user.id == @project.project_leader_id

    flash[:danger] = 'リーダーではない為、権限がありません。'
    redirect_to user_project_path(params[:id])
  end
end