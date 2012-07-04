require 'test_helper'
require 'daemons/npm_monitor'

class NpmMonitorTest < Test::Unit::TestCase

  def setup
    @monitor = NpmMonitor.new
  end

  def teardown
    NpmPackage.unstub(:remote_find_updated_since)
  end

  def test_last_update
    @monitor = NpmMonitor.new(1029)
    assert_equal 1029, @monitor.last_update
  end

  def test_stop?
    assert_equal false, @monitor.stop?
  end

  def test_stop
    @monitor.stop
    assert_equal true, @monitor.stop?
  end

  def test_monitor_changes
    @monitor.expects(:sleep).with(30)
    assert @monitor.monitor_changes?
  end

  def test_start
    response = {
      :changes => [
        { :seq => 1030, :id => 'some-node-package' },
        { :seq => 1031, :id => 'another-package' },
      ],
      :last_seq => 1031
    }

    NpmPackage.stubs(:remote_find_updated_since).returns(response)

    @monitor.expects(:monitor_changes?).times(2).returns(true, false)
    @monitor.expects(:process_changes).once.with(response[:changes])
    @monitor.expects(:set_last_update).once.with(response[:last_seq])
    @monitor.start
  end

  def test_schedule_hooks

  end

end
