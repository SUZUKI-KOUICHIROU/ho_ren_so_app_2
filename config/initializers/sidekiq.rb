# Redisサーバーのデフォルト設定を定義
redis_config = { url: 'redis://redis:6379/0' }

# Sidekiqサーバーの設定
Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'] || redis_config }
  config.logger = Logger.new(File.join(Rails.root, 'log', 'sidekiq.log'))
end

# Sidekiqクライアントの設定
Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'] || redis_config }
end
