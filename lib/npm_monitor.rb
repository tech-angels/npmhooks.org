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

end
