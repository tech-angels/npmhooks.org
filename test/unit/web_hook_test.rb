require 'test_helper'

class WebHookTest < ActiveSupport::TestCase
  should belong_to(:user)
  should validate_presence_of(:user)
  should validate_presence_of(:url)
  should validate_uniqueness_of(:url)

  context 'invoking #success_message' do
    setup do
      @url = 'http://example.com'
      @web_hook = WebHook.new(:url => @url)
    end

    should 'return a success message' do
      assert_equal "Successfully created webhook to #{@url}", @web_hook.success_message
    end
  end

  context 'invoking #removed_message' do
    setup do
      @url = 'http://example.com'
      @web_hook = WebHook.new(:url => @url)
    end

    should 'return a removed message' do
      assert_equal "Successfully removed webhook to #{@url}", @web_hook.removed_message
    end
  end

  context 'invoking #deployed_message' do
    setup do
      @url = 'http://example.com'
      @web_hook = WebHook.new(:url => @url)
    end

    should 'return a success message' do
      assert_equal "Successfully deployed webhook to #{@url}", @web_hook.deployed_message
    end
  end

  context 'invoking #failed_message' do
    setup do
      @url = 'http://example.com'
      @web_hook = WebHook.new(:url => @url)
    end

    should 'return a removed message' do
      assert_equal "There was a problem deploying webhook to #{@url}", @web_hook.failed_message
    end
  end

  context 'invoking #fire' do
    setup do
      @url = 'http://example.com/test'
      @web_hook = WebHook.new(:url => @url)
      @web_hook.stubs(:user).returns(stub(:api_key => '1234'))
      @package_name = 'express'
      @package_version = '2.5.11'
      @change_id = 1030
    end

    context 'with a valid url and not delayed' do
      setup do
        FakeWeb.register_uri(:post, @url, :status => 200)
        @response = @web_hook.fire(@package_name, @package_version, @change_id, false)
      end

      should 'return true' do
        assert @response
      end

      should 'perform a POST request to url' do
        assert_equal Net::HTTP::Post, FakeWeb.last_request.class
        assert_equal '/test', FakeWeb.last_request.path
      end
    end

    context 'with an invalid url and not delayed' do
      setup do
        FakeWeb.register_uri(:post, @url, :status => 500)
      end

      should 'return false' do
        assert !@web_hook.fire(@package_name, @package_version, @change_id, false)
      end
    end

    context 'with a url and delayed' do
      setup do
        Resque.reset!
      end

      should 'queue a job in Resque' do
        @web_hook.fire(@package_name, @package_version, @change_id)
        assert_queued(Notifier, [@url, @package_name, @package_version, @change_id, @web_hook.user.api_key])
      end
    end
  end
end
