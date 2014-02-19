require 'capistrano/ext/multistage'
require 'capistrano-helpers/git'

# RVM
set :rvm_path,          '/usr/local/rvm'
set :rvm_bin_path,      '/usr/local/rvm/bin'
require "rvm/capistrano"

# Set ruby version to use
set :rvm_ruby_string, 'ruby-2.1.0@npmhooks'

# Campfire notifications
# $: << File.join(File.dirname(__FILE__),'..')
# require 'lib/dev_helpers/campfire_deploy_notif'
require 'capistrano-helpers/campfire'
set :campfire_config, "#{ENV['HOME']}/.npmhooks.yml"

# Use bundler with capistrano
require 'bundler/capistrano'

# ==============================================================================
# Application Settings
# ==============================================================================

set :application,     'npmhooks'
set :user,            'deploy'
set :group,           'www-data'
set :repository,      'git@github.com:tech-angels/npmhooks.org.git'
set :deploy_to,       "/var/local/apps/#{application}"
set :ssh_options,     { :forward_agent => true }

set :stages,          %w(production staging)
set :default_stage,   'staging'

set :use_sudo,        false
set :sudo_prompt,     ''

# ==============================================================================
# Server Settings
# ==============================================================================

set :app_server,      'unicorn'

# ==============================================================================
# Restore shared files
# ==============================================================================

require 'capistrano-helpers/shared'
set(:shared) { ['config/application.yml', 'config/database.yml', 'config/initializers/airbrake.rb'] }

namespace :deploy do
  # ==============================================================================
  # Unicorn
  # ==============================================================================
  desc "Restart unicorn"
  task :restart do
    run "kill -s USR2 `cat /var/www/#{application}/#{stage}/shared/pids/unicorn.pid`"
  end

  desc 'Restart Resque workers.'
  task :restart_workers, :roles => :app do
    run "sudo /usr/bin/monit -g resque-npmhooks-#{stage} restart"
  end
end

# Database migration on deploy
after "deploy:update", "deploy:migrate"

after 'deploy:restart', 'deploy:restart_workers'

require 'airbrake/capistrano'
