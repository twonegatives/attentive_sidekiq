module AttentiveSidekiq
  module Middleware
    module Server
      class Attentionist
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
