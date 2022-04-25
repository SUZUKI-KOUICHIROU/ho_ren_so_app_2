# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# 絶対パスから相対パス指定
env :PATH, ENV['PATH']
# ログファイルの出力先
set :output, 'log/cron.log'
# ジョブの実行環境の指定
set :environment, :development, :production
#
# every 12.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 1.days, at: '9:00 am' do

# # Rails内のメソッド実行
#   runner "UserMailer.notify_user"
# end


every 1.days, at: '3:05 pm' do #トリガー
  runner "batch/notice_not_submitted_members.rb" # 毎朝9時にリーダーへ未報告者を報告
  runner "batch/update_deadline.rb" # レポートの期限を更新する
end

every 1.days, at: '7:00 am' do #トリガー
  runner "batch/notice_not_submitted_members.rb" # 毎朝7時に報告未提出メンバーにリマインドを送る
end

# every 1.minutes do #テスト用バッチ処理
#   runner "batch/test.rb"
# end

# Learn more: http://github.com/javan/whenever
