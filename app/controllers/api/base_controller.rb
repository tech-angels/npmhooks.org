class Api::BaseController < ApplicationController
  before_filter :authenticate_with_api_key
  before_filter :verify_authenticated_user

  def authenticate_with_api_key
    api_key = request.headers['Authorization'] || params[:api_key]
    @current_user = User.find_by_api_key(api_key)
  end

  def verify_authenticated_user
    if @current_user.nil?
      render :text => 'Access Denied. Please sign up for an account at https://npmhooks.org', :status => 401
    end
  end
end
