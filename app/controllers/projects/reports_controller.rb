class Projects::ReportsController < Projects::BaseProjectController
  before_action :project_authorization, only: %i[index show new edit create update destroy]
  before_action :project_leader_user, only: %i[view_reports_log]

  # rubocopを一時的に無効にする。
  # rubocop:disable Metrics/AbcSize
  def index
    set_project_and_members
    @first_question = @project.questions.first
    @report_label_name = @first_question.send(@first_question.form_table_type).label_name
    @reports = @project.reports.where.not(sender_id: @user.id).order(created_at: 'DESC').page(params[:page]).per(10)
    @you_reports = @project.reports.where(sender_id: @user.id).order(created_at: 'DESC').page(params[:page]).per(10)
    @monthly_reports = Report.monthly_reports_for(@project)
    @weekly_reports = Report.weekly_reports_for(@project)
    if params[:report_type] == 'monthly'
      @reports = @monthly_reports.where.not(sender_id: @user.id).order(created_at: 'DESC').page(params[:page]).per(10)
      @you_reports = @monthly_reports.where(sender_id: @user.id).order(created_at: 'DESC').page(params[:page]).per(10)
      { reports: @reports, you_reports: @you_reports }
    elsif params[:report_type] == 'weekly'
      @reports = @weekly_reports.where.not(sender_id: @user.id).order(created_at: 'DESC').page(params[:page]).per(10)
      @you_reports = @weekly_reports.where(sender_id: @user.id).order(created_at: 'DESC').page(params[:page]).per(10)
      { reports: @reports, you_reports: @you_reports }
    end
    if params[:search].present? and params[:search] != ""
      @results = Report.search(report_search_params)
      if @results.present?
        @report_ids = @results.pluck(:id).uniq || @results.pluck(:report_id).uniq
      else
        flash.now[:danger] = '検索結果が見つかりませんでした。'
        return
      end
      @reports = @project.reports.where.not(sender_id: @user.id).where(id: @report_ids).order(created_at: 'DESC').page(params[:page]).per(10)
      @you_reports = @project.reports.where(sender_id: @user.id).where(id: @report_ids).order(created_at: 'DESC').page(params[:page]).per(10)
    end
    render :index
  end
  # rubocop:enable Metrics/AbcSize

  def show
    set_project_and_members
    @user = User.find(params[:user_id])
    @report = Report.find(params[:id])
    @answers = @report.answers.order(:id)
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
    @report = @project.reports.new(create_reports_params)
    @report.sender_id = @user.id
    @report.sender_name = @user.name
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
      create_reports_params[:answers_attributes].each do |key, answer|
        res = Answer.find(answer[:id])
        if res.question_type == 'check_box'
          if answer[:array_value].nil?
            res.array_value.clear
            res.save!
          end
        end
      end

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
      link_status = project_mender_or_admin?(@user, project)
      project_date_array = [[:project_name, project.name], [:id, project.id], [:created_at, project.created_at], [:link_on, link_status]]
      project_array = report_rate_for_each_four_weeks + project_date_array + overall_reporting_rate_array
      project_array.to_h
    end
  end

  # 再提出を求める。
  def reject
    @report = Report.find(params[:id])
    @user = current_user
    if params[:report][:remanded_reason] != ""
      @report.update!(params.require(:report).permit(:remanded_reason, :remanded))
      if @report.save
        flash[:success] = "登録完了しました。"
        NotificationMailer.send_rework_notification(@user).deliver_now
      else
        flash[:danger] = "登録に失敗しました。"
      end
    elsif params[:report][:remanded_reason] == ""
      if @report.update!(remanded: false, remanded_reason: nil)
        flash[:success] = "登録に完了しました。"
      else
        flash[:danger] = "登録に失敗しました。"
      end
    end
    redirect_to action: :show
  end

  # 再提出の承認
  def resubmitted
    @report = Report.find(params[:id])
    if @report.update(params.require(:report).permit(:remanded, :resubmitted))
      if @report.update(remanded_reason: nil)
        flash[:success] = "報告手直しを承認しました。"
      end
    else
      flash[:danger] = "登録に失敗しました。"
    end
    redirect_to action: :show
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

  private

  # フォーム新規登録並びに編集用/create
  def create_reports_params
    params.require(:report).permit(:id, :user_id, :project_id, :title, :report_day,
      answers_attributes: [
        :id, :question_type, :question_id, :value, array_value: []
      ])
  end

  def report_search_params
    params.fetch(:search, {}).permit(:title, :created_at, :sender_name, :keywords)
    # fetch(:search, {})と記述することで、検索フォームに値がない場合はnilを返し、エラーが起こらなくなる
    # ここでの:searchには、フォームから送られてくるparamsの値が入っている
  end

  # 報告日のみの検索に使用するパラメーター
  def search_params
    params.permit(:search)
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

  # プロジェクトメンバーかスタッフかを判断する
  def project_mender_or_admin?(user, project)
    if user.project_users.find_by(project_id: project.id).present? || user.admin
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
end
