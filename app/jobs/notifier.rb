class Notifier
  @queue = :web_hooks

  def self.perform(url, package_name, version_cache_id, api_key)
    # @todo
  end
end
