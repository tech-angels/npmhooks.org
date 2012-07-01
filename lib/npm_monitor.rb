require 'net/http'
require 'json'

class NpmMonitor

  attr_reader :database_base_url

  def initialize(database_base_url)
    @database_base_url = database_base_url
  end

  def uri_for_changes(since)
    uri = URI("#{@database_base_url}/_changes")
    params = { :feed => 'longpoll', :since => since.to_i }
    uri.query = URI.encode_www_form(params)
    uri
  end

  def uri_for_package(package)
    uri = URI("#{@database_base_url}/#{package}")
  end

  def get_changes(since)
    res = Net::HTTP.get_response(uri_for_changes(since))
    body = JSON.parse(res.body)
    body['changes']
  end

  def self.github_url(repository)
    return unless repository
    return unless uri = URI.parse(repository['url']).normalize rescue nil
    return unless uri.host == 'github.com'
    return unless match = uri.path.match(/\A\/([^\/]+\/[^\/]+)\.git\z/)
    return "https://github.com/#{match[1]}"
  end

  def self.format_package(package)
    latest = package['versions'][package['dist-tags']['latest']]

    formatted = {
      :authors          => latest['author']['name'],
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
      :source_code_uri  => github_url(latest['repository']),
      :version          => latest['version']
    }

    # Populate dependencies.development from devDependencies
    (latest['devDependencies'] || {}).each_key.sort.each do |name|
      formatted[:dependencies][:development] << {
        :name           => name,
        :requirements   => latest['devDependencies'][name]
      }
    end

    # Populate dependencies.runtime from dependencies
    (latest['dependencies'] || {}).each_key.sort.each do |name|
      formatted[:dependencies][:runtime] << {
        :name           => name,
        :requirements   => latest['dependencies'][name]
      }
    end

    formatted
  end

end
