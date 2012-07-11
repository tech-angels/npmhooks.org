require 'test_helper'

class Api::V1::WebHooksControllerTest < ActionController::TestCase
  def test_logged_out_listing_hooks
    get :index
    assert @response.body =~ /Access Denied/
  end

  def test_logged_out_create_hook
    post :create, :url => 'http://example.com'
    assert @response.body =~ /Access Denied/
    assert_equal 1, WebHook.count
  end
end
