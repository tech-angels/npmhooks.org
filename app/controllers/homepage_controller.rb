class HomepageController < ApplicationController

  def index
    @api_key = current_user.try(:api_key) || 'YOUR_API_KEY'
  end

end
