require 'set'
require 'active_support/inflector'
require 'active_support/core_ext/hash'
require 'concurrent'
require 'attentive_sidekiq/api'
require 'attentive_sidekiq/middleware/server/attentionist'
require 'attentive_sidekiq/middleware/client/attentionist'
require 'attentive_sidekiq/updater_observer'
require 'attentive_sidekiq/manager'
require 'sidekiq/web' unless defined?(Sidekiq::Web)
require 'attentive_sidekiq/web'

module AttentiveSidekiq
  REDIS_SUSPICIOUS_KEY  = "attentive_observed_hash"
  REDIS_DISAPPEARED_KEY = "attentive_disappeared_hash"

  class << self
    attr_writer :logger

    def logger
      @logger ||= Sidekiq.logger
    end
  end
end
