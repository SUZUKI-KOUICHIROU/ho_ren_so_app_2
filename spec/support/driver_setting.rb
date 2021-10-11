RSpec.configure do |config|
  config.before(:each, type: :system) do
    # Spec実行時、ブラウザon
    driven_by(:selenium_chrome)

    # Spec実行時、ブラウザoff
    # driven_by(:selenium_chrome_headless)

    # Spec実行時、ステータスコードを確認したい場合に使用
    # driven_by(:rack_test)
  end

  config.before(:each, type: :system, js: true) do
    if ENV['SELENIUM_DRIVER_URL'].present?
      driven_by :selenium, using: :chrome, options: {
        browser: :remote,
        url: ENV.fetch('SELENIUM_DRIVER_URL'),
        desired_capabilities: :chrome
      }
    else
      driven_by :selenium_chrome_headless
    end
  end
end
