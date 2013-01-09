set :branch,          fetch(:branch, 'master')
set :rails_env,       'staging'
set :user,            'stagingnpmhooks'
set :vhost,           'staging-npmhooks.tech-angels.net'
set :deploy_to,       "/var/www/#{application}/#{stage}"
set :shared_path,     "/var/www/#{application}/#{stage}/shared"

server main_server, :web, :app, :db
role :db, main_server, :primary => true
