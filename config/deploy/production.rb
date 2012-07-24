set :branch,          'master'
set :main_server,     'npmhooks1.tech-angels.net'
set :rails_env,       'production'
set :user,            'prodnpmhooks'
set :vhost,           'prod-npmhooks.tech-angels.net'
set(:deploy_to) {     "/var/www/#{application}/#{stage}" }
set(:shared_path) {   "/var/www/#{application}/#{stage}/shared" }

role :app, main_server
role :web, main_server
