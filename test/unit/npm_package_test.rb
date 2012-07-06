require 'test_helper'

class NpmPackageTest < Test::Unit::TestCase

  def setup
    @database_base_url = ENV['NPM_DATABASE_URL']
  end

  def test_remote_uri_for_changes
    uri = NpmPackage.remote_uri_for_changes(1029)

    assert_kind_of URI, uri
    assert_equal 'feed=longpoll&since=1029', uri.query
  end

  def test_remote_uri_for_package
    uri = NpmPackage.remote_uri_for_package('test')

    assert_kind_of URI, uri
    assert_equal "#{@database_base_url}/test", uri.to_s
  end

  def test_remote_find_updated_since
    changes_url = "#{@database_base_url}/_changes?feed=longpoll&since=1029"
    response = {
      :results => [
        { :seq => 1030, :id => 'some-node-package' },
        { :seq => 1031, :id => 'another-package' },
      ],
      :last_seq => 1031
    }
    FakeWeb.register_uri(:get, changes_url, :body => JSON.dump(response))

    changes = NpmPackage.remote_find_updated_since(1029)

    assert_kind_of Array, changes
    assert_equal 2, changes.length
    assert_equal 1030, changes[0]['seq']
    assert_equal 'some-node-package', changes[0]['id']
    assert_equal 1031, changes[1]['seq']
    assert_equal 'another-package', changes[1]['id']
  end

  def test_remote_find_by_name
    package_url = "#{@database_base_url}/express"
    response = {
      '_id'         => 'express',
      '_rev'        => '302-c61077032ef8b66dccd3b6e94294528a',
      'name'        => 'express',
      'description' => 'Sinatra inspired web development framework'
    }
    FakeWeb.register_uri(:get, package_url, :body => JSON.dump(response))

    package = NpmPackage.remote_find_by_name('express')

    assert_kind_of NpmPackage, package
    assert_equal 'express', package.name
  end

  def test_github_url
    url = NpmPackage.github_url({
      'type'       => 'git',
      'url'        => 'git://github.com/visionmedia/express.git'
    })

    assert_equal 'https://github.com/visionmedia/express', url
  end

  def test_github_url_non_git
    url = NpmPackage.github_url({
      'type'       => 'svn',
      'url'        => 'http://something'
    })

    assert_nil url
  end

  def test_github_url_invalid
    assert_nil NpmPackage.github_url(nil)
  end

  def test_as_json
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

    package = NpmPackage.new(remote_package)

    expected = {
      :authors                => 'TJ Holowaychuk',
      :dependencies           => {
        :development          => [{
          :name               => 'expresso',
          :requirements       => '0.7.2'
        }],
        :runtime              => [{
          :name               => 'connect',
          :requirements       => '>= 1.4.0 < 2.0.0'
        }, {
          :name               => 'mime',
          :requirements       => '>= 0.0.1'
        }, {
          :name               => 'qs',
          :requirements       => '>= 0.0.6'
        }]
      },
      :info                   => 'Sinatra inspired web development framework',
      :name                   => 'express',
      :source_code_uri        => 'https://github.com/visionmedia/express',
      :version                => '2.5.11'
    }

    assert_equal expected, package.as_json
  end

end
