source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'

gem 'bcrypt'
gem 'bootsnap', require: false
gem 'bootstrap', '~> 4.1.1'
gem 'bootstrap-will_paginate'
gem 'cancancan'
gem 'clipboard-rails'
gem 'coffee-rails', '~> 4.2'
gem 'devise'
gem 'devise-i18n'
gem 'devise-i18n-views'
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
gem 'jwt'
gem 'kaminari'
gem 'momentjs-rails'
gem 'payjp'
gem 'puma', '~> 3.11'
gem 'rails', '~> 5.2.6'
gem 'rails-i18n'
gem 'ransack'
gem 'rolify'
gem 'rounding'
gem 'sass-rails', '~> 5.0'
gem 'spring-commands-rspec'
gem 'trix'
gem 'turbolinks', '~> 5'
gem 'uglifier', '>= 1.3.0'
gem 'will_paginate'
gem 'devise_invitable'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails'
  gem 'rspec-rails'
  gem 'sqlite3', '1.3.13'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'rubocop', require: false
  gem 'rubocop-discourse'
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec'
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
  gem 'webdrivers'
end

group :production do
  gem 'pg', '0.20.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
