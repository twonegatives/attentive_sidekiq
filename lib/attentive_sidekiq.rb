require 'attentive_sidekiq/middleware'
require 'attentive_sidekiq/middleware/server/attentionist'
require 'attentive_sidekiq/middleware/client/attentionist'
require 'sidekiq/web' unless defined?(Sidekiq::Web)
require 'attentive_sidekiq/web'
