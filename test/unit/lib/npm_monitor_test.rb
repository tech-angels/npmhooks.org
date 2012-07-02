require 'test_helper'
require 'daemons/npm_monitor'

class NpmMonitorTest < Test::Unit::TestCase

  def setup
    @monitor = NpmMonitor.new
  end

  def test_monitor_changes
    @monitor.expects(:sleep).with(30)
    assert @monitor.monitor_changes?
  end

  def test_process_changes
  #  changes = [
  #    { 'seq' => 1030, 'id' => 'some-node-package' },
  #    { 'seq' => 1031, 'id' => 'another-package' }
  #  ]

  #  @monitor.expects(:schedule_hooks).with('some-node-package')
  #  @monitor.expects(:schedule_hooks).with('another-package')

  #  @monitor.process_changes(changes)
  end

  def test_schedule_hooks

  end

end
