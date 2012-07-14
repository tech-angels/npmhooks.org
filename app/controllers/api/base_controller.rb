class Api::BaseController < ApplicationController
  before_filter :verify_authenticated_user

  private
  def verify_authenticated_user
    if current_user.nil?
      render :text => 'Access Denied. Please sign up for an account at https://npmhooks.org', :status => 401
    end
  end

  def request_api_key
    request.headers['Authorization'] || params[:api_key]
  end

  def current_user
    @current_user = User.find_by_api_key(request_api_key)
  end
end
