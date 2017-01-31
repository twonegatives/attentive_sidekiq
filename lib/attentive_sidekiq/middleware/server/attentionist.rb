module AttentiveSidekiq
  module Middleware
    module Server
      class Attentionist
        def initialize(options = nil)
          return unless options
          AttentiveSidekiq.timeout_interval = options[:timeout_interval] if options.key?(:timeout_interval)
          AttentiveSidekiq.execution_interval = options[:execution_interval] if options.key?(:execution_interval)

          ::Sidekiq.configure_server do |config|
            config.on(:startup) do
              AttentiveSidekiq::Manager.instance.start!
            end
          end
        end

        def call(worker_instance, item, queue)
          Suspicious.add(item)
          yield
        ensure
          Suspicious.remove(item['jid'])
        end
      end
    end
  end
end
