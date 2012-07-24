set :branch,          'develop'
set :rails_env,       'staging'
set :user,            'stagingnpmhooks'
set :vhost,           'staging-npmhooks.tech-angels.net'
set(:deploy_to) {     "/var/www/#{application}/#{stage}" }
set(:shared_path) {   "/var/www/#{application}/#{stage}/shared" }

role :app, 'npmhooks1.tech-angels.net'
role :web, 'npmhooks1.tech-angels.net'
