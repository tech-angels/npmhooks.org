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

  def fire(package_name, package_version, change_id, delayed=true)
    params = [self.url, package_name, package_version, change_id, self.user.api_key]

    if delayed
      Resque.send(:enqueue, *([Notifier] + params))
    else
      @job = Notifier.send(:new, *params)
      @job.perform
    end
  end
end
