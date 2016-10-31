module AttentiveSidekiq
  module Middleware
    module Client
      class Attentionist
        def call(worker_class, item, queue, redis_pool = nil)
          yield
        end
      end
    end
  end
end
