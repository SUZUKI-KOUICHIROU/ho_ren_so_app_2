source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'

gem 'actionmailer'
gem 'activejob'
gem 'activesupport'
gem 'bcrypt'
gem 'bootsnap', require: false
gem 'bootstrap', '~> 4.6.2'
gem 'cancancan'
gem 'chartkick'
gem 'clipboard-rails'
gem 'coffee-rails', '~> 4.2'
gem 'devise'
gem 'devise-i18n'
gem 'dotenv-rails'
gem 'enum_help'
gem 'faker'
gem 'font-awesome-rails'
gem 'font-awesome-sass'
gem 'fullcalendar-rails'
gem 'haml-rails'
gem 'holiday_japan'
gem 'jbuilder', '~> 2.5'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'jwt'
gem 'kaminari'
gem 'momentjs-rails'
gem 'payjp'
gem 'pry-rails'
gem 'puma', '~> 3.11'
gem 'rails', '~> 5.2.6'
gem 'rails-i18n'
gem 'redis'
gem 'rinku'
gem 'rolify'
gem 'rounding'
gem 'sass-rails', '~> 5.0'
gem 'sidekiq'
gem 'slack-ruby-client'
gem 'trix'
gem 'turbolinks', '~> 5'
gem 'uglifier', '>= 1.3.0'
gem 'webpacker', '5.4.3'
gem 'whenever', require: false

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails'
  gem 'letter_opener_web', '~> 1.0'
  gem 'rspec-queue'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'rubocop-discourse'
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec'
  gem 'spring-commands-rspec'
  gem 'sqlite3', '1.3.13'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  # gem 'spring-commands-rspec'
  gem 'spring-watcher-listen', '~> 2.0.0'
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara'
  gem 'database_cleaner'
  gem 'poltergeist'
  gem 'rails-controller-testing'
  gem 'rspec_junit_formatter'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers',
    git: 'https://github.com/thoughtbot/shoulda-matchers.git',
    branch: 'rails-5'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'webdrivers', require: !ENV['SELENIUM_DRIVER_URL']
end

group :production do
  gem 'pg', '0.20.0'
  gem 'aws-sdk-s3'
  gem "dockerfile-rails", ">= 1.6", :group => :development

  gem "net-imap", "~> 0.3.7", :require => false
  gem "net-pop", "~> 0.1.2", :require => false
  gem "net-smtp", "~> 0.4.0", :require => false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
