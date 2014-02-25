class Api::V1::WebHooksController < Api::BaseController
  respond_to :json, :only => :index
  #before_action :load_webhook, only: [:index, :fire, :remove]
  def index
    respond_with current_user.web_hooks
  end

  def create
    webhook = current_user.web_hooks.build(webhook_params)
    if webhook.save
      render(:text => webhook.success_message, :status => :created)
    else
      render(:text => webhook.errors.full_messages, :status => :conflict)
    end
  end

  def remove
    webhook = current_user.web_hooks.where(webhook_params)
    if webhook.try(:destroy)
      render(:text => webhook.removed_message, :status => 200)
    else
      render(:text => 'No such webhook exists under your account.', :status => :not_found)
    end
  end

  def fire
    package = JSON.parse(Redis.current.get('NpmPackage::last_updated_package'), :symbolize_names => true)
    webhook = current_user.web_hooks.new(:url => params[:url])

    if webhook.fire(package[:package_name], package[:version], package[:version_cache_id], false)
      render(:text => webhook.deployed_message)
    else
      render(:text => webhook.failed_message, :status => 400)
    end
  end

  private

    def webhook_params
      params.require(:webhook).permit!
    end
end
