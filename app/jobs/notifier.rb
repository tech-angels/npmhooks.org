class Notifier

  extend Resque::Plugins::ExponentialBackoff
  @queue = :web_hooks

  attr_reader :url, :package_name, :version, :version_cache_id, :api_key

  def initialize(url, package_name, version, version_cache_id, api_key)
    @url              = url
    @package_name     = package_name
    @version          = version
    @version_cache_id = version_cache_id
    @api_key          = api_key
  end

  def authorization
    Digest::SHA2.hexdigest(package_name + version + api_key)
  end

  def payload
    Redis.current.get("NpmPackage::#{package_name}::#{version_cache_id}")
  end

  def perform
    timeout(5) do
      RestClient.post url,
                      payload,
                      :timeout        => 5,
                      :open_timeout   => 5,
                      'Content-Type'  => 'application/json',
                      'Authorization' => authorization
    end
    true
  end

  def timeout(sec, &block)
    Timeout.timeout(sec, &block)
  end

  def self.perform(url, package_name, version, version_cache_id, api_key)
    Notifier.new(url, package_name, version, version_cache_id, api_key).perform
  end
end
