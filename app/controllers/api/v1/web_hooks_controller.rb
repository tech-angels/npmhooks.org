class Api::V1::WebHooksController < Api::BaseController
  def index
    render(:text => 'test')
  end

  def create
    render(:text => 'test')
  end
end
