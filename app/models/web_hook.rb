class WebHook < ActiveRecord::Base
  belongs_to :user

  #attr_accessible :url

  validates_presence_of :user
  validates_presence_of :url
  validates_uniqueness_of :url

  def success_message
    "Successfully created webhook to #{url}"
  end

  def removed_message
    "Successfully removed webhook to #{url}"
  end

  def deployed_message
    "Successfully deployed webhook to #{url}"
  end

  def failed_message
    "There was a problem deploying webhook to #{url}"
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

  def payload
    {
      "failure_count"  => failure_count,
      "url"            => url
    }
  end

  def as_json(options={})
    payload
  end
end
