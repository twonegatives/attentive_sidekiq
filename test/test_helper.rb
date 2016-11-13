ENV['RACK_ENV'] = ENV['RAILS_ENV'] = 'test'

require 'pry'
require 'sidekiq'
require 'sidekiq/api'
require 'sidekiq/cli'
require 'sidekiq/processor'
require 'sidekiq/manager'
require 'sidekiq/util'
require 'sidekiq/redis_connection'
require 'redis-namespace'
require 'attentive_sidekiq'
require 'minitest/unit'
require 'minitest/autorun'
require 'minitest/pride'

REDIS_URL = "redis://localhost:15"
REDIS_NAMESPACE = 'testy'
REDIS = Sidekiq::RedisConnection.create(:url => REDIS_URL, :namespace => REDIS_NAMESPACE)

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add AttentiveSidekiq::Middleware::Server::Attentionist
  end
end
