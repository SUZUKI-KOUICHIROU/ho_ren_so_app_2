module DebugHelper
  # キューに存在しているジョブの情報（ジョブID,ジョブ引数）を表示する
  def disp_job_info(scheduled_set)
    puts ">>> #{scheduled_set.size}個のジョブが待機中"

    # ジョブが存在している場合のみ、ジョブの一覧を表示する
    if scheduled_set.size > 0
      puts "------------------------------"

      scheduled_set.each_with_index do |job, i|
        puts "#{i + 1}番目のジョブ"
        puts "ジョブID：#{job.args.first["job_id"]}"
        puts "引数：#{job.args.first["arguments"]}"
        puts "------------------------------"
      end
    end
  end
end
