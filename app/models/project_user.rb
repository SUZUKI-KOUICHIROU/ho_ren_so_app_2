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
    # タイムゾーンを日本時刻JSTに変換
    self.report_reminder_time = report_time.in_time_zone('Asia/Tokyo')

    save!

    # report_reminder_time の値が返されるよう設定
    self.report_reminder_time
  end

  # 報告リマインダーに対し、リマインド指定日時（reminder_datetime）を計算＆設定するメソッド
  def calculate_reminder_datetime(reminder_days, report_time, next_report_date)
    report_time = Time.zone.parse(report_time)
    reminder_date = next_report_date

    # 選択日数（reminder_days）分の日数を減算して指定日（reminder_date）を設定
    reminder_date -= reminder_days.days if reminder_days.positive?

    # 選択時刻（report_time）を指定日に加えて指定日時（reminder_datetime）を設定
    reminder_datetime = Time.zone.local(
      reminder_date.year,
      reminder_date.month,
      reminder_date.day,
      report_time.hour,
      report_time.min,
      report_time.sec
    )

    # reminder_datetime の値が返されるよう設定
    reminder_datetime
  end

  # 報告リマインドメール送信ジョブをキューに追加するメソッド
  def queue_report_reminder(project_id, member_id, report_frequency, reminder_days, report_time)
    # 設定ボタン押下日＆選択時刻（report_reminder_time）を保存
    self.set_report_reminder_time(report_time)

    # projectsテーブルから次回報告日（next_report_date）を取得
    next_report_date = project.next_report_date

    # 指定日時（reminder_datetime）を計算＆設定
    reminder_datetime = calculate_reminder_datetime(reminder_days, report_time, next_report_date)

    # 指定日時に応じた計1ヶ月分の送信ジョブをキューに追加
    if reminder_datetime.present?
      # 指定日時が過去の場合、次回報告日の報告頻度（report_frequency）日後へと再設定
      if reminder_datetime < Time.current
        recalculated_next_report_date = next_report_date
        recalculated_next_report_date += report_frequency.days

        # 指定日時を再計算＆再設定
        reminder_datetime = calculate_reminder_datetime(reminder_days, report_time, recalculated_next_report_date)

        # 再計算後の指定日時が過去の場合、さらに報告頻度（report_frequency）日後へと再々設定
        if reminder_datetime < Time.current
          recalculated_next_report_date += report_frequency.days

          # 指定日時を再々計算＆再々設定
          reminder_datetime = calculate_reminder_datetime(reminder_days, report_time, recalculated_next_report_date)
        end
      end

      # 1度目のメール送信ジョブをキューに追加（JST時刻）
      ReminderJob.set(wait_until: reminder_datetime).perform_later(project_id, member_id, reminder_days, report_time)

      # 2度目以降の指定日時を計算＆設定
      next_reminder_datetime = reminder_datetime + report_frequency.days

      # 2度目以降～1ヶ月間の継続的なメール送信ジョブをキューに追加（JST時刻）
      while next_reminder_datetime < 1.month.from_now
        ReminderJob.set(wait_until: next_reminder_datetime).perform_later(project_id, member_id, reminder_days, report_time)
        next_reminder_datetime += report_frequency.days # 1ヶ月分、報告頻度ごとに日数を継続加算
      end

    else
      Rails.logger.warn "Invalid report_reminder_datetime: #{reminder_datetime}. #{error_message}"
    end
  end
end
