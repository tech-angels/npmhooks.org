namespace :npm_monitor do
  desc "Start the npm monitor"
  task :start => :environment do
    NpmMonitor.new.start
  end
end
