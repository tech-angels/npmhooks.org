class User < ActiveRecord::Base
  has_many :web_hooks

  before_create :assign_api_key

  def assign_api_key
    self.api_key ||= User.random_unique_key
  end

  def self.random_unique_key
    key = random_key
    return random_unique_key if User.exists?(:api_key => key)
    key
  end

  def self.random_key
    SecureRandom::hex(16)
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
