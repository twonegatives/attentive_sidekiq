module AttentiveSidekiq
  module Middleware
    module Client
      class Attentionist

        def call(worker_class, item, queue, redis_pool = nil)
          yield
        end

        #def call(worker_class, item, queue, redis_pool = nil)
        #  yield
        #  if rerun?(item["jid"])
        #    mark_as_not_lost(item["jid"])
        #  else
        #  add_to_observed_list(item)
        #  end
        #end

        #def rerun?(jid)
        #  Sidekiq.redis{|conn| conn.hexists(AttentiveSidekiq::Middleware::REDIS_KEY, jid) } == 1
      	#end
      end
    end
  end
end
