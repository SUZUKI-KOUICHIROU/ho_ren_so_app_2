class Formats::ReportFormatsController < Formats::BaseFormatController
  # 入力フォーム新規登録アクション
  def create
    @project = Project.find(params[:project_id])
    form_display_order = @project.form_display_orders.build(create_formats_params)
    form_display_order.save
    if form_display_order.save
      flash[:notice] = '入力フォームを新規登録しました。'
    else
      flash[:alert] = '入力フォームの新規登録に失敗しました。'
    end
    redirect_to edit_project_report_format_path(@project)
  end

  # 入力フォーム新規登録用モーダルウインドウ表示アクション
  def new
    @project = Project.find(params[:project_id])
    position = @project.form_display_orders.last.position + 1
    @form_display_order = @project.form_display_orders.build(position: position)
    @form_display_order.build_text_field
    @form_type = :text_field
    @form_table_value = 'text_field'
  end

  # 入力フォーム編集ページ表示アクション
  def edit
    @project = Project.find(params[:project_id])
    @form_display_orders = @project.form_display_orders
  end

  # 入力フォーム編集アクション
  def update
  end

  # 入力フォーム削除アクション
  def destroy
    @project = Project.find(params[:project_id])
    form = FormDisplayOrder.find(params[:form_display_order_id])
    if form.destroy
      flash[:notice] = '入力フォームを削除しました。'
    else
      flash[:alert] = '入力フォームの削除に失敗しました。'
    end
    redirect_to edit_project_report_format_path(@project)
  end

  # 入力フォーム新規登録用モーダルウインドウ内のコンテンツを動的に変化させる処理に関連するajaxアクション
  def replacement_input_forms
    @project = Project.find(params[:project_id])
    position = @project.form_display_orders.last.position + 1
    @form_display_order = @project.form_display_orders.build(position: position)
    case params[:form_type]
    when 'text_field'
      @form_display_order.build_text_field
      @form_type = :text_field
      @form_table_value = 'text_field'
    when 'text_area'
      @form_display_order.build_text_area
      @form_type = :text_area
      @form_table_value = 'text_area'
    when 'radio_button'
      radio_button_object = @form_display_order.build_radio_button
      @form_type = :radio_button
      radio_button_object.radio_button_option_strings.build
      @association_symbol = :radio_button_option_strings
      @form_table_value = 'radio_button'
    when 'check_box'
      check_box_object = @form_display_order.build_check_box
      @form_type = :check_box
      check_box_object.check_box_option_strings.build
      @association_symbol = :check_box_option_strings
      @form_table_value = 'check_box'
    when 'select'
      select_object = @form_display_order.build_select
      @form_type = :select
      select_object.select_option_strings.build
      @association_symbol = :select_option_strings
      @form_table_value = 'select'
    end
  end

  private

  # フォーム新規登録用/create
  def create_formats_params
    params.require(:form_display_order).permit(:position, :form_table_type,
                                               text_field_attributes: %i[label_name field_type],
                                               text_area_attributes: %i[label_name field_type],
                                               radio_button_attributes: [:label_name, :field_type, { radio_button_option_strings_attributes:
                                               [:id, %i[option_string _destroy]] }],
                                               check_box_attributes: [:label_name, :field_type, { check_box_option_strings_attributes:
                                               [:id, %i[option_string _destroy]] }],
                                               select_attributes: [:label_name, :field_type, { select_option_strings_attributes:
                                               [:id, %i[option_string _destroy]] }])
  end

  # フォーム編集用/update
  def update_formats_params
    params.permit(text_field: %i[label_name field_type],
                  text_area: %i[label_name field_type],
                  check_box: %i[label_name field_type],
                  check_box_option_strings: %i[option_string _destroy],
                  radio_button: %i[label_name field_type],
                  radio_button_option_strings: %i[option_string _destroy],
                  select: %i[label_name field_type],
                  select_option: %i[option_string _destroy])
  end
end
