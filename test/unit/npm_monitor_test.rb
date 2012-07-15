require 'test_helper'
require 'npm_monitor'

class NpmMonitorTest < ActiveSupport::TestCase
  def setup
    @monitor = NpmMonitor.new
  end

  def teardown
    NpmPackage.unstub(:remote_find_updated_since)
    NpmPackage.unstub(:remote_find_by_name)
    Redis.current.unstub(:set)
    Redis.current.unstub(:get)
    Redis.current.unstub(:expire)
    WebHook.unstub(:all)
  end

  test '#last_update is nil by default' do
    assert_equal nil, @monitor.last_update
  end

  test '#stop? is false by default' do
    assert_equal false, @monitor.stop?
  end

  test '#stop stops the monitor' do
    @monitor.stop
    assert_equal true, @monitor.stop?
  end

  test '#monitor_changes should sleep before returning true' do
    @monitor.expects(:sleep).with(30)
    assert @monitor.monitor_changes?
  end

  test '#start' do
    response = [
      { 'seq' => 1030, 'id' => 'some-node-package' },
      { 'seq' => 1031, 'id' => 'another-package' }
    ]

    Redis.current.expects(:get).once.with('NpmMonitor::last_update').returns(100)
    NpmPackage.stubs(:remote_find_updated_since).with(100).returns(response)
    @monitor.expects(:monitor_changes?).times(2).returns(true, false)
    @monitor.expects(:process_changes).once.with(response)
    @monitor.start
  end

  test '#start should handle http timeouts and continue' do
    Redis.current.expects(:get).once.with('NpmMonitor::last_update').returns(100)
    NpmPackage.stubs(:remote_find_updated_since).with(100).raises(Timeout::Error)
    @monitor.expects(:monitor_changes?).times(2).returns(true, false)
    @monitor.expects(:process_changes).never
    @monitor.start
  end

  test '#process_changes should call #process_change for each change' do
    changes = [
      { 'seq' => 1030, 'id' => 'some-node-package' },
      { 'seq' => 1031, 'id' => 'another-package' }
    ]

    @monitor.expects(:process_change).once.with(changes[0])
    @monitor.expects(:process_change).once.with(changes[1])
    @monitor.process_changes(changes)
  end

  test '#process_changes with nil should return false' do
    assert_equal false, @monitor.process_changes(nil)
  end

  test '#process_change' do
    change = { 'seq' => 1030, 'id' => 'express' }

    package = {}
    NpmPackage.stubs(:remote_find_by_name).once.with('express').returns(package)
    @monitor.expects(:set_last_update).once.with(1030)
    @monitor.expects(:save_to_cache).once.with(package, 1030)
    @monitor.expects(:schedule_webhooks).once.with(package, 1030)

    @monitor.process_change(change)
  end

  test '#process_change for a delete package' do
    change = { 'seq' => 1030, 'id' => 'deleted_package' }
    NpmPackage.stubs(:remote_find_by_name).once.with('deleted_package').raises(ActiveRecord::RecordNotFound)
    Redis.current.expects(:set).never
    @monitor.expects(:set_last_update).once.with(1030)

    @monitor.process_change(change)
  end

  test '#save_to_cache' do
    package = stub(
      :name => 'express',
      :version => '2.5.11',
      :to_json => {}
    )

    Redis.current.expects(:set).once.with("NpmPackage::express::1030", package.to_json)
    Redis.current.expects(:expire).once.with("NpmPackage::express::1030", 9.hours)
    Redis.current.expects(:set).once.with("NpmPackage::last_updated_package", {
      :package_name     => 'express',
      :version          => '2.5.11',
      :version_cache_id => 1030
    }.to_json)

    @monitor.save_to_cache(package, 1030)
  end

  test '#schedule_webhooks' do
    webhooks = [
      stub(:url => 'http://example.com', :user => stub(:api_key => '1234')),
      stub(:url => 'http://example.org', :user => stub(:api_key => '4567'))
    ]
    package = stub(
      :name => 'express',
      :version => '2.5.11',
      :to_json => {}
    )
    change_id = 1030

    @monitor.expects(:webhooks).once.returns(webhooks)
    @monitor.expects(:schedule_webhook).once.with(webhooks[0], package, change_id)
    @monitor.expects(:schedule_webhook).once.with(webhooks[1], package, change_id)

    @monitor.schedule_webhooks(package, change_id)
  end

  test '#schedule_webhook' do
    webhook = stub(:url => 'http://example.com');
    package = stub(
      :name => 'express',
      :version => '2.5.11'
    )
    change_id = 1030

    webhook.expects(:fire).once.with(package.name, package.version, change_id)

    @monitor.schedule_webhook(webhook, package, change_id)
  end

  test '#set_last_update' do
    Redis.current.expects(:set).once.with('NpmMonitor::last_update', 5)

    @monitor.set_last_update(5)
    assert_equal 5, @monitor.last_update
  end

  test '#set_last_update should not touch the last_update counter if the value is lesser than current' do
    Redis.current.expects(:set).once.with('NpmMonitor::last_update', 5)
    @monitor.set_last_update(5)
    Redis.current.expects(:set).never.with('NpmMonitor::last_update', 1)
    @monitor.set_last_update(1)
    assert_equal 5, @monitor.last_update
  end

  test '#webhooks' do
    WebHook.expects(:all).once.with(:include => :user)
    @monitor.webhooks
  end
end
