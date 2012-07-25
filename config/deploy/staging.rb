set :branch,          'develop'
set :rails_env,       'staging'
set :user,            'stagingnpmhooks'
set :vhost,           'staging-npmhooks.tech-angels.net'
set(:deploy_to) {     "/var/www/#{application}/#{stage}" }
set(:shared_path) {   "/var/www/#{application}/#{stage}/shared" }

set :npm_staging,        'npmhooks1.tech-angels.net'

server npm_staging, :web, :app, :db 
role :db, npm_staging, :primary => true
