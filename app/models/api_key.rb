class ApiKey < ActiveRecord::Base
  belongs_to :user

  before_create :generate_random_key

  def generate_random_key
    self.api_key ||= ApiKey.random_unique_key
  end

  def self.random_unique_key
    key = random_key
    return random_unique_key if ApiKey.exists?(:api_key => key)
    key
  end

  def self.random_key
    SecureRandom::hex(16)
  end
end
