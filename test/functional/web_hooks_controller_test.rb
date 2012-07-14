require 'test_helper'

class Api::V1::WebHooksControllerTest < ActionController::TestCase
  context 'When not logged in' do
    should 'forbid access when listing hooks' do
      get :index
      assert @response.body =~ /Access Denied/
    end

    should 'forbid access when creating a web hook' do
      post :create, :url => 'http://example.com'
      assert @response.body =~ /Access Denied/
      assert_equal 1, WebHook.count
    end

    should 'forbid access when firing a web hook' do
      post :fire, :url => web_hooks(:example).url
      assert @response.body =~ /Access Denied/
    end

    should 'forbid access when deleting a web hook' do
      delete :remove, :url => web_hooks(:example).url
      assert @response.body =~ /Access Denied/
    end
  end

  context 'When logged in' do
    setup do
      @user = users(:cjoudrey)
      @request.env['Authorization'] = @user.api_key
    end

    context 'On GET to index with some owner hooks' do
      setup do
        get :index, :format => :json
      end

      should respond_with :success
      should 'be able to parse body' do
        response = JSON.load(@response.body)
        assert_equal 1, response.length
        assert_equal @user.web_hooks.first.as_json, response[0]
      end
    end

    context 'On POST to create a web hook' do
      setup do
        @url = 'http://example2.com'
        post :create, :url => @url
      end

      should respond_with :created
      should 'have saved the webhook' do
        assert_equal @url, WebHook.last.url
        assert_equal 2, WebHook.count
      end
      should 'link webhook to the current user' do
        assert_equal @user, WebHook.last.user
      end
      should 'say webhook was created' do
        assert_equal @response.body, "Successfully created webhook to #{@url}"
      end
    end

    context 'On POST to create a hook for an existing url' do
      setup do
        @user.web_hooks.build(:url => 'http://example2.com').save
        post :create, :url => 'http://example2.com'
      end

      should respond_with 409
      should 'not have saved the webhook' do
        assert_equal 2, WebHook.count
      end
    end

    context 'On DELETE to remove a hook for an existing url' do
      context 'That user owns' do
        setup do
          @webhook = web_hooks(:example)
          delete :remove, :url => @webhook.url
        end

        should respond_with 200
        should 'have deleted the webhook' do
          assert !WebHook.exists?(@webhook.id)
        end
        should 'say webhook was deleted' do
          assert_equal @response.body, "Successfully removed webhook to #{@webhook.url}"
        end
      end

      context 'That user does not own' do
        setup do
          @url = 'http://something.com'
          @user = User.create
          @webhook = WebHook.new(:url => @url)
          @webhook.user_id = @user.id
          @webhook.save
          delete :remove, :url => @url
        end

        should respond_with 404
        should 'not have deleted the webhook' do
          assert WebHook.exists?(@webhook.id)
        end
      end
    end

    context 'on DELETE to remove a hook for a non existing url' do
      setup do
        delete :remove, :url => 'invalid url'
      end

      should respond_with 404
    end
  end
end
