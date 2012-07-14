require 'test_helper'

class NotifierTest < ActiveSupport::TestCase
  def setup
    Notifier.unstub(:new)

    @webhook = web_hooks(:example)
    @notifier = Notifier.new(
      @webhook.url,
      'express',
      '2.5.11',
      '1234',
      users(:cjoudrey).api_key
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
    FakeWeb.register_uri(
      :post,
      @notifier.url,
      :parameters => @notifier.payload,
      :status => 200
    )

    @notifier.expects(:timeout).once.with(5).yields

    assert_equal true, @notifier.perform
    assert_equal URI(@notifier.url).path, FakeWeb.last_request.path
    assert_equal @notifier.payload, FakeWeb.last_request.body
    assert_equal @notifier.authorization, FakeWeb.last_request['Authorization']
    assert_equal 'application/json', FakeWeb.last_request['Content-Type']
  end

  def test_perform_fail
     FakeWeb.register_uri(
      :post,
      @notifier.url,
      :parameters => @notifier.payload,
      :status => 404
    )

    old_failure_count = @webhook.failure_count

    @notifier.expects(:timeout).once.with(5).yields
    assert_equal false, @notifier.perform
    assert_equal old_failure_count + 1, WebHook.find_by_url(@notifier.url).failure_count
  end

  def test_perform
    Notifier.stubs(:new).once.with(
      web_hooks(:example).url,
      'express', '2.5.11',
      '1234', users(:cjoudrey).api_key
    ).returns(@notifier)
    @notifier.expects(:perform).once

    Notifier.perform(
      web_hooks(:example).url,
      'express', '2.5.11',
      '1234', users(:cjoudrey).api_key
    )
  end
end
