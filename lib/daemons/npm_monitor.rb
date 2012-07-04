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
    while monitor_changes?
      changes = NpmPackage.remote_find_updated_since(last_update)
     # process_changes(changes)
    end
  end

  def set_last_update(last_update)

  end

  def process_changes(changes)

  end

  def schedule_hooks(package_name)
    # Obtain the package info from NPM
    # Save the info into redis for later us
    # Schedule the webhooks
  end

end
