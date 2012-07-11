class User < ActiveRecord::Base
  has_many :web_hooks
  has_many :api_keys

  after_create :auto_assign_api_key

  def auto_assign_api_key
    self.api_keys << ApiKey.create
  end

  def self.from_omniauth(auth)
    where(auth.slice("provider", "uid")).first || create_from_omniauth(auth)
  end

  def self.create_from_omniauth(auth)
    create! do |user|
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.login = auth["info"]["nickname"]
      user.email = auth["info"]["email"]
    end
  end
end
