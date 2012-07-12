require 'test_helper'

class Api::V1::WebHooksControllerTest < ActionController::TestCase

  setup do
    @user = users(:cjoudrey)
  end

  def logged_in
    @request.env['Authorization'] = @user.api_key
  end

  test "When not logged in should forbid access when listing hooks" do
    get :index
    assert @response.body =~ /Access Denied/
  end

  test "When not logged in should forbid access when creating a web hook" do
    post :create, :url => 'http://example.com'
    assert @response.body =~ /Access Denied/
    assert_equal 1, WebHook.count
  end

  test "When not logged in should forbid access when firing a web hook" do
    post :fire, :url => web_hooks(:example).url
    assert @response.body =~ /Access Denied/
  end

  test "When not logged in should forbid access when deleting a web hook" do
    delete :remove, :url => web_hooks(:example).url
    assert @response.body =~ /Access Denied/
  end

  test "When logged in should list web hooks in GET index" do
    logged_in
    get :index, :format => :json
    assert_equal 200, @response.status
    response = JSON.load(@response.body)
    assert_equal 1, response.length
    assert_equal @user.web_hooks.first.as_json, response[0]
  end
end
