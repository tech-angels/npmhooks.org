require 'test_helper'

class NotifierTest < ActiveSupport::TestCase
  def setup
    Notifier.unstub(:new)

    @notifier = Notifier.new(
      web_hooks(:example).url,
      'express',
      '2.5.11',
      '1234',
      api_keys(:cjoudrey_key).api_key
    )
  end

  def test_authorization
    assert_equal '6518c7c2341f12ae24d1541b1586f816f93eb898f76e6ad0774a982bcb848257', @notifier.authorization
  end

  def test_payload
    Redis.current.expects(:get).once.with('NpmPackage::express::1234')
    @notifier.payload
  end

  def test_perform
    Notifier.stubs(:new).once.with(
      web_hooks(:example).url,
      'express', '2.5.11',
      '1234', api_keys(:cjoudrey_key).api_key
    ).returns(@notifier)
    @notifier.expects(:fire).once

    Notifier.perform(
      web_hooks(:example).url,
      'express', '2.5.11',
      '1234', api_keys(:cjoudrey_key).api_key
    )
  end
end
