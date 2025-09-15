source "https://rubygems.org"

ruby "3.4.2"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem "rails", "~> 7.2.2", ">= 7.2.2.2"
# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 7.0"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
# gem "importmap-rails", ">= 0.3.4"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails", ">= 0.7.11"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails", ">= 0.4.0"

# Use SCSS for stylesheets
gem "sassc", "2.4.0"
gem "sassc-rails", "~>2.1.2"
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem "turbolinks", "~> 5"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.14"
# Use Active Model has_secure_password
gem "bcrypt", "~> 3.1.7"

# !!!! Workaround !!!
# This gem is missing in Ruby 3.4.2
gem "irb"
# This gem is added to work around a bundle load problem
gem "ffi", "1.17.2"
# Load bigdecimal and mutex_m because they're no longer in ruby after ruby 3.4.0
gem "bigdecimal", "3.2.3"
gem "mutex_m"
# Load drb because it's no longer in ruby after ruby 3.4.0
gem "drb", "2.2.3"
#  load fiddle because it's no longer in ruby after ruby 3.5.0
gem "fiddle", "1.1.8"
#  load benchmark because it's no longer in ruby after ruby 3.5.0
gem "benchmark"
#  Use concurrent-ruby 1.3.4 until using Rails version 7.1 !!!
gem "concurrent-ruby", "1.3.5"
# Update to rubyzip 3.0
gem 'rubyzip', '~> 3.0'
# !!!! Workarounds over !!!

# This gem is added to work around some already initialized constant errors
# with net/protocol in Ruby version
gem "net-http"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.4.2", require: false

###=================###
### Added gems      ###
###=================###
gem "faker"
# The following are for form help
gem "select2-rails"
gem "simple_form", "~> 5.3", ">= 5.3.1"
gem "cocoon"

# Mail support (validates email format)
gem "email_validator"

# Database.  Using the same database for production/development
gem "pg",  "1.6.2"

# Watir: This is used to scrape data from the NFL.com site
gem "watir"

# Gems for adding SMS support
gem "phonelib"
gem "twilio-ruby", ">= 7.8.0"

#
# Bootstrap support gems
#
gem "bootstrap", "4.6.2"
gem "jquery-rails"
gem "will_paginate-bootstrap4"
# Fontawesome fonts
gem "font-awesome-rails"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  gem "rspec-rails", "~> 8.0"
  # Adds support for Capybara system testing and selenium driver
  gem "capybara", "3.40.0"
  gem "capybara-email"
  gem "selenium-webdriver", "4.35"

  # Add support to create test factories using FactoryBot
  gem "factory_bot_rails", ">= 6.5.1"
  gem "pry"
  gem "pry-byebug" # Recommended for step-by-step debugging
  gem "pry-rails"
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in
  # the code.
  gem "web-console", ">= 4.1.0"
  gem "listen", "~> 3.2"
  # automate testing with Guard
  # gem 'guard', '2.17.0'
  # gem 'guard-rspec', '4.7.3'
  gem "annotate"
  gem "letter_opener_web"
  gem "childprocess"
end

group :test do
  # gem 'webdrivers' # Not needed with latest version of Selenium-webdriver and ruby 3+
  # Email support
  gem "email_spec"
  # Added gems
  gem "database_cleaner"
  # Code coverage tool
  gem "simplecov", require: false, group: :test
  gem "launchy"
  # gem 'rubocop-rspec'
end

gem "execjs"
