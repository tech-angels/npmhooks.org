redis_connection = Redis.new({
  :host     => ENV['REDIS_HOST'] || '127.0.0.1',
  :port     => ENV['REDIS_PORT'] || 6379,
  :password => ENV['REDIS_PASSWORD'] || nil,
  :timeout  => ENV['REDIS_TIMEOUT'] || 5.0,
  :database => ENV['REDIS_DATABASE'] || 0,
})

Redis.current = redis_connection
