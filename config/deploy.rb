require 'capistrano/ext/multistage'
require 'capistrano-helpers/git'

# RVM
set :rvm_path,          '/usr/local/rvm'
set :rvm_bin_path,      '/usr/local/rvm/bin'
require "rvm/capistrano"

# Set ruby version to use
set :rvm_ruby_string, 'ruby-1.9.3-p194@npmhooks'

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
set(:shared) { ["config/environments/#{stage}.yml", 'config/database.yml'] }

# ==============================================================================
# Unicorn
# ==============================================================================

# Originally copied from smtlaissezfaire / cap_unicorn
namespace :unicorn do
  desc "Restart unicorn"
  task :restart do
    run "oldpid=$(cat /var/www/#{application}/#{stage}/shared/pids/unicorn.pid) && kill -s USR2 $oldpid && echo 'Searching for newly spawned master process...' && until (pid=$(cat /var/www/#{application}/#{stage}/shared/pids/unicorn.pid 2>/dev/null) && test '$pid' != '$oldpid' && ps x |grep $pid|grep master) ; do sleep 1 ; done && kill -s WINCH $oldpid && kill -s QUIT $oldpid"
  end
end

namespace :deploy do
  desc "Restart the unicorn workers"
  task :restart do
    unicorn.restart
  end
end

# ==============================================================================
# Resque
# ==============================================================================

namespace :deploy do
  desc 'Restart Resque workers.'
  task :restart_workers, :roles => :app do
    run "sudo /usr/sbin/monit -g resque-npmhooks-#{stage} restart"
  end
end

after 'deploy:restart', 'deploy:restart_workers'
