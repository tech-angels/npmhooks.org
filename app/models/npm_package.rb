require 'net/http'

class NpmPackage
  def initialize(package)
    @package = package
  end

  def name
    @package['name']
  end

  def version
    @package['dist-tags']['latest']
  end

  def as_json(options=nil)
    latest = @package['versions'][version]
    # Some packages doesn't have the latest dist-tags. It might be due to a failed
    # partial publish prior to npm v1.3.19.
    # cf: https://twitter.com/indexzero/status/441326968336699392/photo/1
    raise Exceptions::IncompletePackage if latest.nil?

    hash = {
      :authors          => NpmPackage.author_name_from_package(latest),
      :dependencies     => {
        :development    => [],
        :runtime        => []
      },
      :dependencies     => {
        :development    => [],
        :runtime        => []
      },
      :info             => latest['description'],
      :name             => latest['name'],
      :source_code_uri  => NpmPackage.github_url(latest['repository']),
      :version          => latest['version']
    }

    # Populate dependencies.development from devDependencies
    (latest['devDependencies'] || {}).each_key.sort.each do |name|
      hash[:dependencies][:development] << {
        :name           => name,
        :requirements   => latest['devDependencies'][name]
      }
    end

    # Populate dependencies.runtime from dependencies
    (latest['dependencies'] || {}).each_key.sort.each do |name|
      hash[:dependencies][:runtime] << {
        :name           => name,
        :requirements   => latest['dependencies'][name]
      }
    end

    hash
  end

  def self.author_name_from_package(package)
    package['author'] ? package['author'].try(:[], 'name') : nil
  end

  def self.remote_uri_for_changes(since)
    uri = URI("#{ENV['NPM_DATABASE_URL']}/_changes")
    params = { :feed => 'longpoll', :since => since.to_i }
    uri.query = URI.encode_www_form(params)
    uri
  end

  def self.remote_uri_for_last_change_id
    uri = URI("#{ENV['NPM_DATABASE_URL']}/_changes")
    params = { :descending => 'true', :limit => 1  }
    uri.query = URI.encode_www_form(params)
    uri
  end

  def self.remote_uri_for_package(package)
    URI("#{ENV['NPM_DATABASE_URL']}/#{package}")
  end

  def self.remote_find_updated_since(since)
    res = Net::HTTP.get_response(remote_uri_for_changes(since))
    body = JSON.parse(res.body)
    body['results'].delete_if { |x| x['id'] =~ /\// }
  end

  def self.remote_find_by_name(package)
    res = Net::HTTP.get_response(remote_uri_for_package(package))
    response = JSON.parse(res.body)
    raise Exceptions::PackageNotFound if response['error'] == 'not_found'

    # When a new package is added, there is no 'versions' entries
    # until the 2nd or 3rd save.
    raise Exceptions::IncompletePackage if !response['versions'] || response['versions'].keys.length == 0

    NpmPackage.new(response)
  end

  def self.remote_last_change_id
    res = Net::HTTP.get_response(remote_uri_for_last_change_id)
    response = JSON.parse(res.body, :symbolize_names => true)
    response[:last_seq].to_i
  end

  def self.github_url(repository)
    return unless repository
    return unless uri = URI.parse(repository['url']).normalize rescue nil
    return unless uri.host == 'github.com'
    return unless match = uri.path.match(/\A\/([^\/]+\/[^\/]+)\.git\z/)
    "https://github.com/#{match[1]}"
  end
end
