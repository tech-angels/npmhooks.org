require 'test_helper'

class HomepageControllerTest < ActionController::TestCase
  context 'When not logged in' do
    should 'display homepage with API_KEY' do
      get :index
      assert @response.body =~ /YOUR_API_KEY/
    end
  end
  context 'When logged in' do
    setup do
      @user = users(:cjoudrey)
      session[:user_id] = @user.id
      get :index
    end
    should "display user's api_key" do
      assert @response.body =~ /#{@user.api_key}/
    end
  end
end
