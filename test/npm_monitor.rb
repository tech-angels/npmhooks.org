require File.expand_path('test_helper', File.dirname(__FILE__))
require File.expand_path('../lib/npm_monitor', File.dirname(__FILE__))

class NpmMonitorTest < Test::Unit::TestCase

  def setup
    @database_base_url = 'http://127.0.0.1/registry'
    @monitor = NpmMonitor.new(@database_base_url)
    FakeWeb.clean_registry
  end

  def test_database_base_url
    assert_equal @database_base_url, @monitor.database_base_url
  end

  def test_uri_for_changes
    uri = @monitor.uri_for_changes('1029')

    assert_kind_of URI, uri
    assert_equal 'feed=longpoll&since=1029', uri.query
  end

  def test_uri_for_package
    uri = @monitor.uri_for_package('test')

    assert_kind_of URI, uri
    assert_equal "#{@database_base_url}/test", uri.to_s
  end

  def test_get_changes
    changes_url = "#{@database_base_url}/_changes?feed=longpoll&since=1029"
    response = {
      :changes => [
        { :seq => 1030, :id => "some-node-package" },
        { :seq => 1031, :id => "another-package" },
      ],
      :last_seq => 1031
    }
    FakeWeb.register_uri(:get, changes_url, :body => JSON.dump(response))

    changes = @monitor.get_changes(1029)

    assert_kind_of Array, changes
    assert_equal 2, changes.length
    assert_equal 1030, changes[0]['seq']
    assert_equal 'some-node-package', changes[0]['id']
    assert_equal 1031, changes[1]['seq']
    assert_equal 'another-package', changes[1]['id']
  end

end
