class ProjectUser < ApplicationRecord
  belongs_to :user
  belongs_to :project

  # プロジェクトメンバーそれぞれに報告集計メンバーの除外ステータスを追加する
  def self.member_expulsion_join(project, members)
    project_member_expulsions = project.project_users.all
    members.each do |member|
      member.member_expulsion = project_member_expulsions.find_by(user_id: member.id).member_expulsion
    end
    return members
  end

  # 報告リマインダーに対し、選択時刻で設定を行うメソッド
  def set_report_reminder_time(report_time)
    # report_timeをTime型に変換
    report_time = Time.zone.parse(report_time)
    # タイムゾーンをJSTに変換
    self.report_reminder_time = report_time.in_time_zone('Asia/Tokyo')

    save!

    # 追加: ログ出力
    logger.debug "Report reminder time set for user #{user_id} in project #{project_id} at #{self.report_reminder_time}"

    # reminder_time が返されるよう設定
    self.report_reminder_time
  end

  # 報告リマインダーに対し、選択した日にち＆時刻で設定を行うメソッド
  def calculate_reminder_time(report_frequency, reminder_days, report_time, next_report_date) # 引数に次回報告日を追加
    report_time = Time.zone.parse(report_time)
    reminder_time = next_report_date

    # 追加: ログ出力
    logger.debug "Next Report Date: #{reminder_time}"

    # reminder_days が 0 より大きい場合、日数を減算
    reminder_time -= reminder_days.days if reminder_days.positive?

    # report_time が指定されている場合は、その時刻に設定
    reminder_time = reminder_time.change(hour: report_time.hour, min: report_time.min) if report_time.present?

    # 追加: ログ出力
    logger.debug "Calculated reminder time for user #{user_id} in project #{project_id} is #{reminder_time}"

    reminder_time
  end

  # キューにリマインドジョブを追加するメソッド
  def queue_report_reminder(project_id, member_id, report_frequency, reminder_days, report_time, next_report_date) # 引数に次回報告日を追加
    # set_report_reminder_time を使って report_reminder_time を設定
    self.set_report_reminder_time(report_time)

    reminder_time = calculate_reminder_time(report_frequency, reminder_days, report_time, next_report_date) # 引数に次回報告日を追加

    # 追加: ログ出力
    logger.debug "Queued report reminder job for user #{member_id} in project #{project_id} at #{reminder_time}"

    # 報告リマインド時刻が未来の日時かどうかを確認
    if reminder_time.present?

      # 指定時刻が過去の場合、next_report_date の (report_frequency - reminder_days) 日後に更新
      if reminder_time < Time.current
        next_report_date += (report_frequency - reminder_days).days
        reminder_time = calculate_reminder_time(report_frequency, reminder_days, report_time, next_report_date)
      end
      
      # 指定時刻が過去の場合、next_report_date の (report_frequency - reminder_days) 日後に更新
      # reminder_time += (report_frequency - reminder_days).days if reminder_time < Time.current

      # 1度目のメール送信ジョブをキューに追加（JST時刻）
      ReminderJob.set(wait_until: reminder_time).perform_later(project_id, member_id, reminder_days, report_time)

      # 翌日以降～1ヶ月間、継続して同じ指定時刻に送信するよう、次回のジョブをキューに追加（JST時刻）
      next_reminder_time = reminder_time + report_frequency.days # 報告頻度ごとに日数を加算
      while next_reminder_time < 1.month.from_now
        ReminderJob.set(wait_until: next_reminder_time).perform_later(project_id, member_id, report_frequency, reminder_days, report_time)
        next_reminder_time += report_frequency.days # 報告頻度ごとに日数を加算
      end
    else
      Rails.logger.warn "Invalid report_reminder_time: #{reminder_time}. #{error_message}"
    end
  end
end
