source 'https://rubygems.org'

gem 'rails', '3.2.17'
# Even it's shipped with rails, ensure we get latest security fix
# gem 'json', '>=1.7.7'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'pg'
gem "twitter-bootstrap-rails", "~> 2.2.8"
gem 'sqlite3'
gem 'omniauth'
gem 'omniauth-github'
gem 'redis', '~> 3.0.1'
gem 'resque'
gem 'resque-retry'
gem 'gravatar_image_tag'
gem 'rest-client'
gem 'haml'
gem "therubyracer"
gem "less-rails" #Sprockets (what Rails 3.1 uses for its asset pipeline) supports LESS

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

group :development do
  gem 'capistrano'
  gem 'capistrano-ext'
  gem 'capistrano-helpers', github: "westarete/capistrano-helpers"
  gem 'tinder'
  gem 'rvm-capistrano'
end

group :test do
  gem 'fakeweb'
  gem 'mocha', :require => nil
  gem 'resque_unit'
  gem 'validates_formatting_of'
  gem 'shoulda'
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
gem 'unicorn'

# To use debugger
# gem 'debugger'

gem "airbrake"
