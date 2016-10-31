module AttentiveSidekiq
  module Middleware
    module Server
      class Attentionist
        def call(worker_instance, item, queue)
          yield
        end
      end
    end
  end
end
