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

  # 報告リマインダーに対し、設定ボタンの押下日＆選択時刻をカラム保存するメソッド
  def set_report_reminder_time(report_time)
    # report_timeをTime型に変換
    report_time = Time.zone.parse(report_time)
    # タイムゾーンをJSTに変換
    self.report_reminder_time = report_time.in_time_zone('Asia/Tokyo')

    save!

    # 追加: ログ出力
    logger.debug "カラム保存したリマインド時刻（Report reminder time） set for user #{user_id} in project #{project_id} at #{self.report_reminder_time}"

    # report_reminder_time の値が返されるよう設定
    self.report_reminder_time
  end

  # 報告リマインダーに対し、選択日数＆選択時刻でリマインド日時を計算＆設定するメソッド
  def calculate_reminder_datetime(report_frequency, reminder_days, report_time, next_report_date)
    report_time = Time.zone.parse(report_time)
    reminder_date = next_report_date

    # 選択日数（reminder_days）分の日数を減算してリマインド日（reminder_date）を設定
    reminder_date -= reminder_days.days if reminder_days.positive?
    logger.debug "リマインド日（After subtracting reminder_days, reminder_date） is #{reminder_date}"

    # 選択時刻（report_time）をリマインド日（reminder_date）に加えてリマインド日時を設定
    reminder_datetime = Time.zone.local(reminder_date.year,
                                        reminder_date.month,
                                        reminder_date.day,
                                        report_time.hour,
                                        report_time.min,
                                        report_time.sec)
    logger.debug "リマインド日時（After setting report_time, reminder_datetime） is #{reminder_datetime}"

    # ログ出力
    logger.debug "リマインド指定日時（Calculated reminder time） for user #{user_id} in project #{project_id} is #{reminder_datetime}"

    # reminder_datetime の値が返されるよう設定
    reminder_datetime
  end

  # キューにリマインドジョブを追加するメソッド
  def queue_report_reminder(project_id, member_id, report_frequency, reminder_days, report_time, next_report_date)
    # set_report_reminder_time を使って report_reminder_time を設定
    self.set_report_reminder_time(report_time)

    # 指定日時（reminder_datetime）を初期設定
    reminder_datetime = calculate_reminder_datetime(report_frequency, reminder_days, report_time, next_report_date)

    # 追加: ログ出力
    logger.debug "リマインドメール指定日時（Queued report reminder job） for user #{member_id} in project #{project_id} at #{reminder_datetime}"

    # 報告リマインド時刻が未来の日時かどうかを確認
    if reminder_datetime.present?
      # 指定日時が過去の場合、次回報告日（next_report_date）の報告頻度（report_frequency）日後を指定日時に再設定
      if reminder_datetime < Time.current
        recalculated_next_report_date = next_report_date # 元々の次回報告日（next_report_date）の値を取得
        recalculated_next_report_date += report_frequency.days # 報告頻度（report_frequency）日分を加算
        
        # 選択時刻も過去時刻の場合、さらに報告頻度（report_frequency）日分を再加算
        if self.report_reminder_time < Time.current
           # 報告頻度（report_frequency）日分を再加算
          recalculated_next_report_date += report_frequency.days
           # ボタン押下日＆選択時刻の値にも報告頻度（report_frequency）日分を加算
          self.report_reminder_time += report_frequency.days
        end

        # 指定日時（reminder_datetime）を再計算＆再設定
        reminder_datetime = calculate_reminder_datetime(report_frequency, reminder_days, report_time, recalculated_next_report_date)

        # 追加: ログ出力
        logger.debug "元々の次回報告日（Next Report date）: #{next_report_date}"
        logger.debug "再計算後の次回報告日（Recalculate Next Report date）: #{recalculated_next_report_date}"
        logger.debug "再計算した1度目のリマインド日時（Recalculated reminder time）: #{reminder_datetime}"
      end

      # 追加: ログ出力
      logger.debug "変わらないハズの次回報告日（Next Report date）: #{next_report_date}"
      logger.debug "正しく設定したリマインド指定日時（Reminder Datetime）: #{reminder_datetime}"

      # 1度目のメール送信ジョブをキューに追加（JST時刻）
      ReminderJob.set(wait_until: reminder_datetime).perform_later(project_id, member_id, report_frequency, reminder_days, report_time)

      # 翌日以降～1ヶ月間、継続して同じ指定時刻に送信するよう、次回のジョブをキューに追加（JST時刻）
      next_reminder_datetime = reminder_datetime + report_frequency.days # 報告頻度ごとに日数を加算

      # 追加: ログ出力
      logger.debug "1度目のリマインド指定日時（Reminder Datetime）: #{reminder_datetime}"
      logger.debug "2度目～1ヶ月間のリマインド指定日時（Next Reminder Datetime）: #{next_reminder_datetime}"
      
      while next_reminder_datetime < 1.month.from_now
        ReminderJob.set(wait_until: next_reminder_datetime).perform_later(project_id, member_id, report_frequency, reminder_days, report_time)
        next_reminder_datetime += report_frequency.days # 報告頻度ごとに日数を加算
      end

      # 追加: ログ出力
      logger.debug "1度目のリマインド指定日時（Reminder Datetime）: #{reminder_datetime}"
      logger.debug "再計算した2度目～1ヶ月間のリマインド指定日時（Next Reminder Datetime）: #{next_reminder_datetime}"
    else
      Rails.logger.warn "Invalid report_reminder_datetime: #{reminder_datetime}. #{error_message}"
    end
  end
end
