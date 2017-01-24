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
  module_function

  DEFAULTS = {
    timeout_interval: 60,
    execution_interval: 600,
  }

  REDIS_SUSPICIOUS_KEY  = "attentive_observed_hash"
  REDIS_DISAPPEARED_KEY = "attentive_disappeared_hash"

  def timeout_interval
    options.fetch(:timeout_interval) do
      options[:timeout_interval] = DEFAULTS.fetch(:timeout_interval)
    end
  end

  def timeout_interval=(timeout_interval)
    options[:timeout_interval] = timeout_interval
  end

  def execution_interval
    options.fetch(:execution_interval) do
      options[:execution_interval] = DEFAULTS.fetch(:execution_interval)
    end
  end

  def execution_interval=(execution_interval)
    options[:execution_interval] = execution_interval
  end

  def logger
    @logger ||= Sidekiq.logger
  end

  def logger=(logger)
    @logger = logger
  end

  def options
    Sidekiq.options.fetch(:attentive) do
      Sidekiq.options[:attentive] =
        Sidekiq.options.fetch("attentive") do
          {}
        end.with_indifferent_access
    end
  end
end

AttentiveSidekiq::Manager.instance.start! if Sidekiq.server?
