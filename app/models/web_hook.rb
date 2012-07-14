class WebHook < ActiveRecord::Base
  belongs_to :user

  attr_accessible :url

  validates_presence_of :user
  validates_presence_of :url
  validates_uniqueness_of :url

  def success_message
    "Successfully created webhook to #{url}"
  end

  def removed_message
    "Successfully removed webhook to #{url}"
  end
end
