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
  DEFAULTS = {
    timeout_interval: 60,
    execution_interval: 600
  }

  REDIS_SUSPICIOUS_KEY  = "attentive_observed_hash"
  REDIS_DISAPPEARED_KEY = "attentive_disappeared_hash"

  class << self
    attr_writer :timeout_interval, :execution_interval, :logger

    def timeout_interval
      return @timeout_interval if @timeout_interval
      @timeout_interval = options[:timeout_interval] || DEFAULTS[:timeout_interval]
    end

    def execution_interval
      return @execution_interval if @execution_interval
      @execution_interval = options[:execution_interval] || DEFAULTS[:execution_interval]
    end

    def logger
      @logger ||= Sidekiq.logger
    end

    def options
      Sidekiq.options[:attentive] || Sidekiq.options['attentive'] || {}
    end
  end
end

AttentiveSidekiq::Manager.instance.start! if Sidekiq.server?
