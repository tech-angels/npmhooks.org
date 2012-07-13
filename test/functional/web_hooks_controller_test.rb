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
    assert_response 200
    response = JSON.load(@response.body)
    assert_equal 1, response.length
    assert_equal @user.web_hooks.first.as_json, response[0]
  end

  test "When logged in should be able to create a web hook" do
    logged_in
    post :create, :url => 'http://example2.com'
    assert_response 201
    assert_equal 2, WebHook.count
    assert_equal @user, WebHook.last.user
    assert_equal 'http://example2.com', WebHook.last.url
  end

  test "When logged in should not be able to create a web hook for an existing url" do
    logged_in
    @user.web_hooks.build(:url => 'http://example2.com').save
    post :create, :url => 'http://example2.com'
    assert_response 409
    assert_equal 2, WebHook.count
  end
end
