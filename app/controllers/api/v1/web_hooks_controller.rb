class Api::V1::WebHooksController < Api::BaseController
  respond_to :json, :only => :index

  def index
    respond_with @current_user.web_hooks
  end

  def create
    webhook = @current_user.web_hooks.build(:url => params[:url])

    if webhook.save
      render(:text => '@todo', :status => :created)
    else
      render(:text => '@todo', :status => :conflict)
    end
  end

  def remove
    render(:text => '@todo')
  end

  def fire
    render(:text => '@todo')
  end
end
