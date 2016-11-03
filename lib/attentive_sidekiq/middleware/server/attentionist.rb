module AttentiveSidekiq
  module Middleware
    module Server
      class Attentionist

        def call(worker_instance, item, queue)
          add_to_observed_list(item)
          yield
        ensure
          mark_as_not_lost(item["jid"])
        end

        def mark_as_not_lost(jid)
          Sidekiq.redis{|conn| conn.hdel(AttentiveSidekiq::Middleware::REDIS_KEY, jid)}
        end

        def add_to_observed_list(item)
          Sidekiq.redis{ |conn| conn.hset(AttentiveSidekiq::Middleware::REDIS_KEY, item['jid'], item.to_json) }
        end
      end
    end
  end
end
