class NpmMonitor

  def initialize
    @logger = Logger.new("#{Rails.root}/log/npmmonitor_#{ENV['RAILS_ENV']}.log")
    @stop = false
    @last_update = nil
  end

  def stop
    @stop = true
  end

  def stop?
    @stop
  end

  def last_update
    return @last_update if @last_update

    @logger.info('Loading last_update from Redis')
    @last_update ||= Redis.current.get('NpmMonitor::last_update')
    return @last_update if @last_update

    @logger.info('Loading last_update from remote')
    @last_update ||= NpmPackage.remote_last_change_id
    @last_update
  end

  def monitor_changes?
    @logger.info("Sleeping...")
    sleep(30)
    !stop?
  end

  def start
    @logger.info("Last update: #{last_update}")
    while monitor_changes?
      @logger.info("Fetching changes since: #{last_update}")
      begin
        changes = NpmPackage.remote_find_updated_since(last_update)
      rescue Timeout::Error
        @logger.error("Timeout!")
        next
      end

      process_changes(changes)
    end
  end

  def process_changes(changes)
    return false if !changes
    @logger.info("Processing #{changes.length} changes")
    changes.each do |change|
      process_change(change)
    end
  end

  def process_change(change)
    @logger.info("Processing: #{change['id']}")

    begin
      package = NpmPackage.remote_find_by_name(change['id'])
      save_to_cache(package, change['seq'])
      schedule_webhooks(package, change['seq'])
    rescue Exceptions::PackageNotFound
      @logger.info("#{change['id']} has been deleted.")
      # @todo schedule deleted webhooks
    rescue Exceptions::IncompletePackage
      @logger.info("#{change['id']} is incomplete. It might have just been created?")
    ensure
      set_last_update(change['seq'])
    end
  end

  def save_to_cache(package, change_id)
    @logger.info("Saving to Redis under NpmPackage::#{package.name}::#{change_id}")
    Redis.current.set("NpmPackage::#{package.name}::#{change_id}", package.to_json)
    Redis.current.expire("NpmPackage::#{package.name}::#{change_id}", 9.hours)
    Redis.current.set('NpmPackage::last_updated_package', {
      :package_name     => package.name,
      :version          => package.version,
      :version_cache_id => change_id
    }.to_json)
  end

  def schedule_webhooks(package, change_id)
    webhooks.each do |webhook|
      schedule_webhook(webhook, package, change_id)
    end
  end

  def schedule_webhook(webhook, package, change_id)
    @logger.info("Scheduling webhook on #{webhook.url} for #{package.name} v#{package.version}")
    webhook.fire(package.name, package.version, change_id)
  end

  def webhooks
    WebHook.all(:include => :user)
  end

  def set_last_update(new_last_update)
    return if new_last_update < last_update.to_i
    @logger.info("Setting last update to: #{new_last_update}")
    @last_update = new_last_update
    Redis.current.set('NpmMonitor::last_update', @last_update)
  end

end
