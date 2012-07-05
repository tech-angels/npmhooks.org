class NpmMonitor

  def initialize(last_update = nil)
    @stop = false
    @last_update = last_update
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
    sleep(30)
    !stop?
  end

  def start
    @last_update = Redis.current.get('NpmMonitor::last_update')

    while monitor_changes?
      changes = NpmPackage.remote_find_updated_since(last_update)
      process_changes(changes)
    end
  end

  def process_changes(changes)
    changes.each do |change|
      process_change(change)
    end
  end

  def process_change(change)
    package = NpmPackage.remote_find_by_name(change['id'])
    Redis.current.set("NpmPackage::#{package.name}", package.to_json)
    # @todo schedule webhooks
    set_last_update(change['seq'])
  end

  def set_last_update(new_last_update)
    @last_update = new_last_update
    Redis.current.set('NpmMonitor::last_update', last_update)
  end

end
