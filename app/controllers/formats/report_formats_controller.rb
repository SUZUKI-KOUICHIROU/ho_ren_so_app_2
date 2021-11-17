class Formats::ReportFormatsController < Formats::BaseFormatController
  # 報告フォーマット新規登録アクション
  def create
  end

  # 報告フォーマット新規登録用モーダルウインドウ表示アクション
  def new
    @project = Project.find(params[:project_id])
    position = @project.form_display_orders.last.position + 1
    @form_display_order = @project.form_display_orders.build(position: position)
    @text_field = @form_display_order.build_text_field
  end

  # 報告フォーマット編集ページ表示アクション
  def edit
    @project = Project.find(params[:project_id])
    @form_display_orders = @project.form_display_orders
    @form_display_order = FormDisplayOrder.new
  end

  # 報告フォーマット内容編集アクション
  def update
  end

  # 報告フォーマット削除アクション
  def destroy
  end

  def replacement_input_forms
    @project = Project.find(params[:project_id])
    position = @project.form_display_orders.last.position + 1
    @form_display_order = @project.form_display_orders.build(position: position)
    case params[:form_type]
    when 'text_field'
      @text_field = @form_display_order.build_text_field
    when 'text_area'
      @text_area = @form_display_order.build_text_area
    when 'check_box'
      @check_box = @form_display_order.build_check_box
      @option_string = @check_box.check_box_option_strings.build
    when 'radio_button'
      @radio_button = @form_display_order.build_radio_button
      @radio_button_option_string = @radio_button.radio_button_option_strings.build
    when 'select'
      @select = @form_display_order.build_select
      @select_option_string = @select.select_option_strings.build
    end
  end

  private

  # フォーマット編集用/update
  def update_formats_params
    params.permit(text_field: [:label_name, :field_type],
                  text_area: [:label_name, :field_type],
                  check_box: [:label_name, :field_type],
                  check_box_option_strings: [:option_string, :_destroy],
                  radio_button: [:label_name, :field_type],
                  radio_button_option_strings: [:option_string, :_destroy],
                  select: [:label_name, :field_type],
                  select_option: [:option_string, :_destroy])
  end

  def new_formats_params
    params.require(:form_display_order).permit(:position, text_field: [:label_name, :field_type],
                                               text_area: [:label_name, :field_type],
                                               check_box: [:label_name, :field_type],
                                               check_box_option_strings: [:option_string, :_destroy],
                                               radio_button: [:label_name, :field_type],
                                               radio_button_option_strings: [:option_string, :_destroy],
                                               select: [:label_name, :field_type],
                                               select_option: [:option_string, :_destroy])
  end
end
