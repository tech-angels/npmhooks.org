GravatarImageTag.configure do |config|
  config.secure = %w(staging production).include?(Rails.env)
end
