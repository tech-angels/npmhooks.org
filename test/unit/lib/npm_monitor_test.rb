require 'test_helper'
require 'daemons/npm_monitor'

class NpmMonitorTest < Test::Unit::TestCase

  def setup
    @monitor = NpmMonitor.new
  end

  def teardown
    NpmPackage.unstub(:remote_find_updated_since)
    NpmPackage.unstub(:remote_find_by_name)
    Redis.current.unstub(:set)
    Redis.current.unstub(:get)
  end

  def test_last_update
    assert_equal nil, @monitor.last_update
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

  def test_start_with_timeout
    Redis.current.expects(:get).once.with('NpmMonitor::last_update').returns(100)
    NpmPackage.stubs(:remote_find_updated_since).with(100).raises(Timeout::Error)
    @monitor.expects(:monitor_changes?).times(2).returns(true, false)
    @monitor.expects(:process_changes).never
    @monitor.start
  end

  def test_process_changes
    changes = [
      { 'seq' => 1030, 'id' => 'some-node-package' },
      { 'seq' => 1031, 'id' => 'another-package' }
    ]

    @monitor.expects(:process_change).once.with(changes[0])
    @monitor.expects(:process_change).once.with(changes[1])
    @monitor.process_changes(changes)
  end

  def test_process_changes_with_no_changes
    assert_equal false, @monitor.process_changes(nil)
  end

  def test_process_change
    remote_package = {
      '_id'         => 'express',
      '_rev'        => '302-c61077032ef8b66dccd3b6e94294528a',
      'name'        => 'express',
      'description' => 'Sinatra inspired web development framework',
      'dist-tags'   => {
        '3.0'       => '3.0.0beta3',
        'latest'    => '2.5.11'
      },
      'versions'    => {
        '2.5.11'      => {
          'name'         => 'express',
          'description'  => 'Sinatra inspired web development framework',
          'version'      => '2.5.11',
          'author'       => {
            'name'         => 'TJ Holowaychuk',
            'email'        => 'tj@vision-media.ca'
          },
          'contributors' => [],
          'dependencies' => {
            'connect'      => '>= 1.4.0 < 2.0.0',
            'mime'         => '>= 0.0.1',
            'qs'           => '>= 0.0.6'
          },
          'devDependencies' => {
            'expresso'        => '0.7.2',
          },
          'keywords'     => [],
          'repository'   => {
              'type'       => 'git',
              'url'        => 'git://github.com/visionmedia/express.git'
          },
          'main'         => 'index',
          'bin'          => {
              'express'    => './bin/express'
          },
          'engines'     => {
              'node'      => '>= 0.4.1 < 0.5.0'
          },
          '_id'              =>  'express@2.3.5',
          '_engineSupported' => true,
          '_npmVersion'      => '1.0.3',
          '_nodeVersion'     => 'v0.4.7',
          '_defaultsLoaded'  => true,
          'dist'             => {
              'shasum'         => 'a3113d0d9db4ea118e2c12b044a04c16741e799b',
              'tarball'        => 'http://registry.npmjs.org/express/-/express-2.3.5.tgz'
          },
          'scripts'          => {},
          'directories'      => {}
        }
      }
    }

    change = { 'seq' => 1030, 'id' => 'some-node-package' }

    package = NpmPackage.new(remote_package)
    NpmPackage.stubs(:remote_find_by_name).once.with('some-node-package').returns(package)
    Redis.current.expects(:set).once.with("NpmPackage::#{package.name}::1030", package.to_json)
    @monitor.expects(:set_last_update).once.with(1030)

    @monitor.process_change(change)
  end

  def test_set_last_update
    Redis.current.expects(:set).once.with('NpmMonitor::last_update', 5)

    @monitor.set_last_update(5)
    assert_equal 5, @monitor.last_update
  end

  def test_set_last_update_lesser
    @monitor.set_last_update(5)
    Redis.current.expects(:set).never.with('NpmMonitor::last_update', 1)
    @monitor.set_last_update(1)
    assert_equal 5, @monitor.last_update
  end


end
