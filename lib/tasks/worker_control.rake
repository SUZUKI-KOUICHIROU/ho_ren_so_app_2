namespace :worker do
  desc "Start worker dyno"
  task start: :environment do
    heroku = PlatformAPI.connect_oauth(ENV['HEROKU_API_KEY'])
    heroku.formation.update(ENV['HEROKU_APP_NAME'], 'worker', {
      quantity: 1
    })
    puts "Worker started"
  end

  desc "Stop worker dyno"
  task stop: :environment do
    heroku = PlatformAPI.connect_oauth(ENV['HEROKU_API_KEY'])
    heroku.formation.update(ENV['HEROKU_APP_NAME'], 'worker', {
      quantity: 0
    })
    puts "Worker stopped"
  end
end
