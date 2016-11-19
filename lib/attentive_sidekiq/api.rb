module AttentiveSidekiq
  class RedisBasedHash
    class << self
      def jobs
        Sidekiq.redis{|conn| conn.hvals(hash_name)}.map{|i| JSON.parse(i)}
      end

      def job_ids
        jobs.map{|i| i["jid"]}
      end

      def add item
        Sidekiq.redis{ |conn| conn.hset(hash_name, item['jid'], item.to_json) }
      end
      
      def remove jid
        Sidekiq.redis{|conn| conn.hdel(hash_name, jid)}
      end

      private

      def hash_name
        self.const_get(:HASH_NAME)
      end
    end
  end
  
  class Disappeared < RedisBasedHash
    HASH_NAME = AttentiveSidekiq::Middleware::REDIS_DISAPPEARED_KEY
    STATUS_DETECTED = 'detected'

    class << self
      alias_method :base_add, :add
      
      def add item
        extended_item = {'noticed_at' => Time.now.to_i, 'status' => STATUS_DETECTED}.merge(item)
        super extended_item
      end
  end
  
  class Suspicious < RedisBasedHash
    HASH_NAME = AttentiveSidekiq::Middleware::REDIS_SUSPICIOUS_KEY
  end

  class Active
    class << self
      def jobs
        Sidekiq::Workers.new.to_a.map{|i| i[2]["payload"]}
      end

      def job_ids
        Set.new(jobs.map{|i| i["jid"]})
      end
    end
  end
end
