class Projects::ReportsController < Projects::BaseProjectController
  require 'csv'
  before_action :project_authorization, only: %i[index show new edit create update destroy]
  before_action :project_leader_user, only: %i[view_reports_log view_reports_log_month]
  before_action :authorize_user!, only: %i[edit update destroy]

  def index
    set_project_and_members
    @reports_all = @project.reports
    @first_question = @project.questions.first
    @report_label_name = @first_question.send(@first_question.form_table_type).label_name
    monthly_reports
    if params[:report_type] == 'monthly'
      monthly_reports
    elsif params[:report_type] == 'weekly'
      weekly_reports
    end
    reports_by_search
    respond_to do |format|
      format.html
      format.js
    end
    render :index
  end

  def show
    set_project_and_members
    @user = User.find(params[:user_id])
    @report = Report.find(params[:id])
    @answers = @report.answers.order(:id)
    @project = Project.find(params[:project_id])
    if current_user && current_user.id == @project.leader_id
      # 既読フラグを設定
      @report.update(report_read_flag: true)
    end

    @reply = @report.report_replies.new
    @report_replies = @report.report_replies.all.order(:created_at)
  end

  def new
    @user = User.find(params[:user_id])
    @project = Project.find(params[:project_id])
    @projects = @user.projects
    @report = @user.reports.build(project_id: @project.id)
    @answer = @report.answers.new
    @questions = @project.questions.where(using_flag: true)
  end

  def edit
    @user = current_user
    @project = Project.get_report_questions_includes(params[:project_id])
    @report = Report.includes(:answers).find(params[:id])
    @user = User.find(@report.user_id)
    @questions = @project.questions.where(using_flag: true).order(:id)
    @answers = @report.answers.order(:id)
  end

  # rubocopを一時的に無効にする。
  # rubocop:disable Metrics/AbcSize
  def create
    @user = User.find(params[:user_id])
    @project = Project.find(params[:project_id])
    unless params[:report][:images].nil?
      set_enable_images(params[:report][:image_enable], params[:report][:images])
    end
    @report = @project.reports.new(create_reports_params)
    @report.sender_id = @user.id
    @report.sender_name = @user.name
    @report.report_read_flag = false
    @report.answers.each do |answer|
      answer.question_name = answer.question_type.camelize.constantize.find_by(question_id: answer.question_id).label_name
    end
    if @report.save
      flash[:success] = '報告を登録しました。'
      @project.report_statuses.find_by(user_id: @user.id, is_newest: true).update(has_submitted: true)
      redirect_to user_project_report_path(@user, @project, @report)
    else
      flash[:danger] = '報告の登録に失敗しました。'
      render :new
    end
  end

  # rubocopを一時的に無効にする。
  def update
    @user = current_user
    @project = Project.get_report_questions_includes(params[:project_id])
    @report = Report.includes(:answers).find(params[:id])
    ActiveRecord::Base.transaction do
      # rubocop:disable Lint/UnusedBlockArgument
      create_reports_params[:answers_attributes].each do |key, answer|
        res = Answer.find(answer[:id])
        if res.question_type == 'check_box'
          if answer[:array_value].nil?
            res.array_value.clear
            res.save!
          end
        end
      end
      # rubocop:enable Lint/UnusedBlockArgument

      @report.update!(create_reports_params)
      flash[:success] = "報告を編集しました。"
      redirect_to user_project_report_path(@user, @project, @report)
    end
  rescue
    flash[:success] = "更新に失敗しました"
    @questions = @project.questions.where(using_flag: true)
    @answers = @report.answers
    render :edit
  end
  # rubocop:enable Metrics/AbcSize

  def destroy
    @user = current_user
    @project = Project.find(params[:project_id])
    @report = Report.find(params[:id])
    if @report.destroy
      flash[:success] = "報告を削除しました。"
    else
      flash[:danger] = "報告の削除に失敗しました。"
    end
    redirect_to user_project_reports_path(@user, @project)
  end

  # 全プロジェクト報告集計画面表示
  def all_project_reporting_rate
    @user = current_user
    @report_days_for_each_four_weeks = four_weeks_from_yesterday_array
    # プロジェクトの情報とそのプロジェクトの報告率の値を持つ配列を代入
    @projects = Project.all.map do |project|
      aggregated_users = Report.get_aggregated_members(project)
      @four_weeks_report_rate_array = []
      @n = 5
      # プロジェクトの一週間の報告率を４週間分のハッシュの配列として代入
      report_rate_for_each_four_weeks = @report_days_for_each_four_weeks.map do |one_week|
        @n -= 1
        one_week_reports_rate = one_week_report_rate_calc(project, one_week, aggregated_users)
        @four_weeks_report_rate_array = @four_weeks_report_rate_array.push(one_week_reports_rate)
        ["rate_week#{@n}".to_sym, "#{one_week_reports_rate}%"]
      end
      overall_reporting_rate_array = [[:overall_reporting_rate, "#{overall_report_rate_calc(@four_weeks_report_rate_array)}%"]]
      link_status = project_leader?(@user, project)
      project_date_array = [[:project_name, project.name], [:id, project.id], [:created_at, project.created_at], [:link_on, link_status]]
      project_array = report_rate_for_each_four_weeks + project_date_array + overall_reporting_rate_array
      project_array.to_h
    end
  end

  # 報告集計画面(一週間)
  def view_reports_log
    @user = User.find(params[:user_id])
    @project = Project.find(params[:project_id])
    @users = @project.project_users.where(member_expulsion: false).map(&:user)
    @display = params[:display].presence || "percent"
    @display_days = params[:display_days].presence || "percent"
    @week_first_day, @week_last_day = calculate_week_dates
    @report_days = @project.report_deadlines.where(day: @week_first_day..@week_last_day)
    weekly_graph_daily_data # 報告日ごとのデータロード
    weekly_graph_user_data # 報告者ごとのデータロード
    if @project.reports.where(report_day: @week_first_day..@week_last_day).empty?
      flash.now[:notice] = "#{@week_first_day.strftime('%-m月%-d日')}～#{@week_last_day.strftime('%-m月%-d日')}の報告はありません。"
    end
  end

  # 報告集計画面(一か月、期間指定)
  def view_reports_log_month
    @user = User.find(params[:user_id])
    @project = Project.find(params[:project_id])
    @users = @project.project_users.where(member_expulsion: false).map(&:user)
    @display = params[:display].presence || "percent"
    @display_days = params[:display_days].presence || "percent"
    @first_day, @last_day = calculate_month_dates
    @month_field_value = @first_day.strftime("%Y-%m-%d")
    @report_days = @project.report_deadlines.where(day: @first_day..@last_day)
    monthly_graph_daily_data # 報告日ごとのデータロード
    monthly_graph_user_data # 報告者ごとのデータロード
    month_no_report_noitce
  end

  def report_form_switching
    @user = User.find(params[:user_id])
    @project = Project.find(params[:project_id])
    @projects = @user.projects
    @report = @user.reports.build(project_id: @project.id)
    @answer = @report.answers.build
    @questions = @project.questions.where(using_flag: true)
  end

  # 報告履歴
  def history
    set_project_and_members
    @report = @project.reports
    @report_history = all_reports_history_month
    @reports_by_search = report_search_params.to_h
    all_reports_history_month
    reports_history_by_search
    respond_to do |format|
      format.html
      format.csv do |_csv|
        send_reports_csv(@report_history)
      end
    end
  end

  private

  def authorize_user!
    @report = Report.find(params[:id])
    unless current_user.id == @report.user_id
      flash[:alert] = "アクセス権限がありません"
      redirect_to root_path
    end
  end

  # フォーム新規登録並びに編集用/create
  def create_reports_params
    params.require(:report).permit(:id, :user_id, :project_id, :title, :report_day,
      answers_attributes: [
        :id, :question_type, :question_id, :value, array_value: []
      ],
      images: [])
  end

  # 報告一覧デフォルト表示、今月の報告
  def monthly_reports
    @monthly_reports = Report.monthly_reports_for(@project)
    @you_reports = @monthly_reports.where(sender_id: @user.id).order(created_at: 'DESC').page(params[:you_reports_page]).per(10)
    @reports = @monthly_reports.where.not(sender_id: @user.id).order(created_at: 'DESC').page(params[:reports_page]).per(10)
    @all_reports = @monthly_reports.all.order(created_at: 'DESC').page(params[:all_reports_page]).per(10)
  end

  # 報告一覧、今週の報告
  def weekly_reports
    @weekly_reports = Report.weekly_reports_for(@project)
    @you_reports = @weekly_reports.where(sender_id: @user.id).order(created_at: 'DESC').page(params[:you_reports_page]).per(10)
    @reports = @weekly_reports.where.not(sender_id: @user.id).order(created_at: 'DESC').page(params[:reports_page]).per(10)
    @all_reports = @weekly_reports.all.order(created_at: 'DESC').page(params[:all_reports_page]).per(10)
  end

  # 報告検索(報告一覧)
  def reports_by_search
    if params[:search].present? and params[:search] != ""
      @results = Report.search(report_search_params)
      if @results.present?
        @report_ids = @results.pluck(:id).uniq || @results.pluck(:report_id).uniq
        @report_history = all_reports_history.where(id: @report_ids)
        @you_reports = @you_reports.where(id: @report_ids)
        @reports = @reports.where(id: @report_ids)
        @all_reports = @all_reports.where(id: @report_ids)
      else
        flash.now[:danger] = '検索結果が見つかりませんでした。' if @results.blank?
      end
    end
  end

  # 報告検索(報告履歴)
  def reports_history_by_search
    if params[:search].present? and params[:search] != ""
      @results = Report.search(report_search_params)
      if @results.present?
        @report_ids = @results.pluck(:id).uniq || @results.pluck(:report_id).uniq
        @report_history = all_reports_history.where(id: @report_ids)
      else
        flash.now[:danger] = '検索結果が見つかりませんでした。' if @results.blank?
      end
    end
  end

  def report_search_params
    params.fetch(:search, {}).permit(:created_at, :keywords)
    # fetch(:search, {})と記述することで、検索フォームに値がない場合はnilを返し、エラーが起こらなくなる
    # ここでの:searchには、フォームから送られてくるparamsの値が入っている
  end

  # 報告日のみの検索に使用するパラメーター
  def search_params
    params.permit(:search)
  end

  # 全報告
  def all_reports_history
    @project.reports.all.order(created_at: 'DESC').page(params[:page]).per(30)
  end

  # 報告履歴の月検索
  def all_reports_history_month
    selected_month = params[:month]
    if selected_month.present?
      start_date = Date.parse("#{selected_month}-01")
      end_date = start_date.end_of_month.end_of_day
      reports = @project.reports.where(created_at: start_date..end_date).order(created_at: 'DESC').page(params[:page]).per(30)
    else
      reports = all_reports_history
    end
    reports
  end

  # CSVエクスポート
  def send_reports_csv(reports)
    bom = "\uFEFF"
    csv_data = CSV.generate(bom, encoding: Encoding::SJIS, row_sep: "\r\n", force_quotes: true) do |csv|
      column_names = %w(報告者 件名 報告日)
      csv << column_names
      reports.each do |report|
        column_values = [
          report.sender_name,
          report.title,
          report.created_at.strftime("%m月%d日 %H:%M"),
        ]
        csv << column_values
      end
    end
    send_data(csv_data, filename: "報告履歴.csv")
  end

  # 昨日もしくは、送られた最終報告集計日から４週間を一週間ごとに配列に代入
  def four_weeks_from_yesterday_array
    four_weeks_last_rate_day = if search_params[:search].present?
                                 search_params[:search].to_date
                               else
                                 Date.yesterday
                               end
    one_week_last_rate_day = four_weeks_last_rate_day
    one_week_first_rate_day = four_weeks_last_rate_day - 6
    return (1..4).map do |n|
      if n == 1
        one_week_first_rate_day..one_week_last_rate_day
      elsif n > 1
        n_week_ago = (n - 1)
        n_week_ago.weeks.before(one_week_first_rate_day)..n_week_ago.weeks.before(one_week_last_rate_day)
      end
    end
  end

  # プロジェクトメンバー全員の一週間の報告率を計算して返す
  def one_week_report_rate_calc(project, one_week, members)
    project_four_weeks_reports_size = Report.befor_deadline_reports_size(Report.get_aggregated_reports(project, one_week, members))
    return (project_four_weeks_reports_size.quo(7 * members.size).to_f * 100).floor
  end

  # プロジェクトリーダーかを判断する
  def project_leader?(current_user, project)
    if current_user.id == project.leader_id
      return true
    else
      return false
    end
  end

  # 総合報告率の計算
  def overall_report_rate_calc(reports_rate_array)
    return reports_rate_array.sum.quo(reports_rate_array.size).to_f.floor
  end

  # 一週間集計の日付を計算
  def calculate_week_dates
    if params[:date].present?
      selected_day = Date.parse(params[:date])
      [selected_day, selected_day + 6]
    elsif params[:weekday].present?
      selected_weekday = params[:weekday].to_i
      week_last_day = Date.current.beginning_of_week + selected_weekday - 1.day
      [week_last_day - 6.days, week_last_day]
    else
      [Date.current - 6, Date.current]
    end
  end

  # 一か月集計、期間指定集計の日付を計算
  def calculate_month_dates
    if params[:date].present?
      selected_date = Date.parse(params[:date] + "-01")
      [selected_date.beginning_of_month, selected_date.end_of_month]
    elsif params[:start_date].present? && params[:end_date].present?
      [Date.parse(params[:start_date]), Date.parse(params[:end_date])]
    else
      current_date = Date.current
      [current_date.beginning_of_month, current_date.end_of_month]
    end
  end

  # 一か月集計、報告が無い場合のフラッシュメッセージ
  def month_no_report_noitce
    if @project.reports.where(report_day: @first_day..@last_day).empty?
      if params[:start_date].present? && params[:end_date].present?
        flash.now[:notice] = "#{@first_day.strftime('%-m月%-d日')}～#{@last_day.strftime('%-m月%-d日')}の報告はありません。"
      else
        flash.now[:notice] = "#{@first_day.strftime('%-m月')}の報告はありません。"
      end
    end
  end

  # １週間集計、グラフデータ(報告日別)
  def weekly_graph_daily_data
    @report_data = {}
    @week_first_day.upto(@week_last_day) do |date|
      reported_users = 0
      @users.each do |user|
        user_report = user.reports.find_by(project_id: @project.id, report_day: date)
        if user_report.present? && user_report.created_at.to_date == date
          reported_users += 1
        end
      end
      total_count = @project.users.where(project_users: { member_expulsion: false }).count # この日の全ユーザー数を計算
      report_percentage = reported_users.to_f / total_count * 100
      @report_data[date] = report_percentage.round(2) # 小数点第二位までの割合
    end
  end

  # １週間集計、グラフデータ(報告者別)
  def weekly_graph_user_data
    @report_user_data = {}
    @users.each do |user|
      reported_days = @project.reports
                              .joins(user: :project_users)
                              .where(report_day: @week_first_day..@week_last_day, user_id: user.id, project_users: { member_expulsion: false })
                              .pluck(:report_day).uniq
      valid_reported_days = reported_days.select { |day| user.reports.find_by(report_day: day).created_at.to_date == day }
      total_days = @report_days.count
      if total_days > 0
        report_percentage = valid_reported_days.count * 100 / total_days
        @report_user_data[user.name] = report_percentage.round(2) # 小数点第二位までの割合
      else
        @report_user_data[user.name] = 0
      end
    end
  end

  # １か月集計、グラフデータ(報告日別)
  def monthly_graph_daily_data
    @report_data = {}
    @first_day.upto(@last_day) do |date|
      reported_users = 0
      @users.each do |user|
        user_report = user.reports.find_by(project_id: @project.id, report_day: date)
        if user_report.present? && user_report.created_at.to_date == date
          reported_users += 1
        end
      end
      total_count = @project.users.where(project_users: { member_expulsion: false }).count # この日の全ユーザー数を計算
      report_percentage = reported_users.to_f / total_count * 100
      @report_data[date] = report_percentage.round(2) # 小数点第二位までの割合
    end
  end

  # １か月集計、グラフデータ(報告者別)
  def monthly_graph_user_data
    @report_user_data = {}
    @users.each do |user|
      reported_days = @project.reports
                              .joins(user: :project_users)
                              .where(report_day: @first_day..@last_day, user_id: user.id, project_users: { member_expulsion: false })
                              .pluck(:report_day).uniq
      valid_reported_days = reported_days.select { |day| user.reports.find_by(report_day: day).created_at.to_date == day }
      total_days = @report_days.count
      if total_days > 0
        report_percentage = valid_reported_days.count * 100 / total_days
        @report_user_data[user.name] = report_percentage.round(2) # 小数点第二位までの割合
      else
        @report_user_data[user.name] = 0
      end
    end
  end
end
