class Formats::ReportFormatsController < Formats::BaseFormatController
  # 入力フォーム新規登録アクション
  def create
    @project = Project.find(params[:project_id])
    form_display_order = @project.form_display_orders.build(create_formats_params)
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
    @position_value = @project.form_display_orders.last.position + 1
    @form_table_type_value = 'text_field'
    @form_type_symbol = :text_field
    @form_display_orders_build_object = @project.form_display_orders.build
    @form_display_orders_build_object.build_text_field
  end

  # 入力フォーム編集ページ表示アクション
  def edit
    @project = Project.find(params[:project_id])
    @form_display_orders = @project.form_display_orders.order(:position)
    @form_number = 0
  end

  # 入力フォーム編集アクション
  def update
    @project = Project.find(params[:project_id])
    params = update_formats_params[:form_display_order_attributes]
    params.each do |fdo_id, items|
      form_display_order_object = FormDisplayOrder.find(fdo_id)
      form_display_order_object.update(items)
    end
    flash[:notice] = '入力項目のデータを更新しました。'
    redirect_to edit_project_report_format_path(@project)
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
    @position_value = @project.form_display_orders.last.position + 1
    @form_display_orders_build_object = @project.form_display_orders.build
    case params[:form_type]
    when 'text_field'
      @form_display_orders_build_object.build_text_field
      @form_type_symbol = :text_field
      @form_table_type_value = 'text_field'
    when 'text_area'
      @form_display_orders_build_object.build_text_area
      @form_type_symbol = :text_area
      @form_table_type_value = 'text_area'
    when 'date_field'
      @form_display_orders_build_object.build_date_field
      @form_type_symbol = :date_field
      @form_table_type_value = 'date_field'
    when 'radio_button'
      @radio_button_build_object = @form_display_orders_build_object.build_radio_button
      @form_type_symbol = :radio_button
      @option_strings_build_object = @radio_button_build_object.radio_button_option_strings.build
      @form_option_symbol = :radio_button_option_strings
      @form_table_type_value = 'radio_button'
    when 'check_box'
      @check_box_build_object = @form_display_orders_build_object.build_check_box
      @form_type_symbol = :check_box
      @check_box_build_object.check_box_option_strings.build
      @form_option_symbol = :check_box_option_strings
      @form_table_type_value = 'check_box'
    when 'select'
      @select_build_object = @form_display_orders_build_object.build_select
      @form_type_symbol = :select
      @select_build_object.select_option_strings.build
      @form_option_symbol = :select_option_strings
      @form_table_type_value = 'select'
    end
  end

  private

  # フォーム新規登録並びに編集用/create
  def create_formats_params
    params.require(:form_display_order).permit(:id, :form_table_type, :position,
                                               text_field_attributes: %i[id label_name field_type],
                                               text_area_attributes: %i[id label_name field_type],
                                               date_field_attributes: %i[id label_name field_type],
                                               radio_button_attributes: [:id, :label_name, :field_type, { radio_button_option_strings_attributes:
                                               [%i[id option_string _destroy]] }],
                                               check_box_attributes: [:id, :label_name, :field_type, { check_box_option_strings_attributes:
                                               [%i[id option_string _destroy]] }],
                                               select_attributes: [:id, :label_name, :field_type, { select_option_strings_attributes:
                                               [%i[id option_string _destroy]] }])
  end

  def update_formats_params
    params.permit(form_display_order_attributes:
                  [:id, [:id, :form_table_type, :position, :using_flag, { text_field_attributes: %i[id label_name field_type],
                                                            text_area_attributes: %i[id label_name field_type],
                                                            date_field_attributes: %i[id label_name field_type],
                                                            radio_button_attributes:
                                                            [:id, :label_name, :field_type,
                                                             { radio_button_option_strings_attributes:
                                                              %i[id option_string _destroy] }],
                                                             check_box_attributes:
                                                             [:id, :label_name, :field_type,
                                                              { check_box_option_strings_attributes:
                                                             %i[id option_string _destroy] }],
                                                             select_attributes:
                                                             [:id, :label_name, :field_type,
                                                              { select_option_strings_attributes:
                                                              %i[id option_string _destroy] }] }]])
  end
end
