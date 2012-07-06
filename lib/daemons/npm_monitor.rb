class NpmMonitor

  def initialize
    @logger = Logger.new(STDOUT)
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
    @last_update
  end

  def monitor_changes?
    @logger.info("Sleeping...")
    sleep(30)
    !stop?
  end

  def start
    @last_update = Redis.current.get('NpmMonitor::last_update')
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
    package = NpmPackage.remote_find_by_name(change['id'])
    @logger.info("Saving to Redis under NpmPackage::#{package.name}::#{change['seq']}")
    Redis.current.set("NpmPackage::#{package.name}::#{change['seq']}", package.to_json)
    # @todo set an expire on the redis npmpackage key
    # @todo schedule webhooks
    set_last_update(change['seq'])
  end

  def set_last_update(new_last_update)
    @logger.info("Setting last update to: #{new_last_update}")
    @last_update = new_last_update
    Redis.current.set('NpmMonitor::last_update', last_update)
  end

end
