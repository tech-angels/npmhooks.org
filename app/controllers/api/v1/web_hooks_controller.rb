class Api::V1::WebHooksController < Api::BaseController
  respond_to :json, :only => :index

  def index
    respond_with @current_user.web_hooks
  end

  def create
    render(:text => 'test')
  end

  def remove
    render(:text => 'test')
  end

  def fire
    render(:text => 'test')
  end
end
