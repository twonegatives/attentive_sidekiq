module AttentiveSidekiq
  module Middleware
    module Client
      class Attentionist
        def call(worker_class, item, queue, redis_pool = nil)
          # TODO: we could backup job info here aswell
          # this would lead us to the need of more complex records filtering
          yield
        end
      end
    end
  end
end
