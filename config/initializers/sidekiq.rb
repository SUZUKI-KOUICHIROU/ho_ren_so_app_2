# SidekiqがRedisに接続する為の基本的な設定。
# 環境変数を使用した、開発・テスト・本番の各環境で異なるRedis URLの設定。
# Docker環境でのデフォルト設定として適切なフォールバックURLの設定。

Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'] || 'redis://redis:6379/0' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'] || 'redis://redis:6379/0' }
end
