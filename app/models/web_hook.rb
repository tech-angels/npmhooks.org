class WebHook < ActiveRecord::Base
  belongs_to :user

  attr_accessible :url

  validates_uniqueness_of :url, :scope => :user_id
end
