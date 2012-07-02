class NpmMonitor

  #def monitor(since)
  #  while monitor_changes?
  #    changes = NpmPackage.remote_find_update_since(since)
  #    process_changes(changes)
  #    since = changes.max
  #  end
  #end

  def monitor_changes?
    sleep(30)
    true
  end

  def process_changes(changes)

  end

  def schedule_hooks(package_name)

  end

end
