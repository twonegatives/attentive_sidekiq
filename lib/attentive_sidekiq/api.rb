module AttentiveSidekiq
  class RedisBasedHash
    class << self
      def jobs
        Sidekiq.redis{|conn| conn.hvals(hash_name)}.map{|i| JSON.parse(i)}
      end

      def job_ids
        jobs.map{|i| i["jid"]}
      end

      def get_job jid
        JSON.parse(Sidekiq.redis{|conn| conn.hget(hash_name, jid)})
      end

      def add item
        Sidekiq.redis{ |conn| conn.hset(hash_name, item['jid'], item.to_json) }
      end

      def remove jid
        Sidekiq.redis{|conn| conn.hdel(hash_name, jid)}
      end
    end
  end

  class Disappeared < RedisBasedHash
    STATUS_DETECTED = 'detected'
    STATUS_REQUEUED = 'requeued'

    class << self
      alias_method :base_add, :add

      def add item
        extended_item = {'noticed_at' => Time.now.to_i, 'status' => STATUS_DETECTED}.merge(item)
        super extended_item
      end

      def requeue jid
        record = get_job(jid)
        Sidekiq::Client.push(
          'class' => record['class'],
          'args'  => record['args'],
          'queue' => record['queue'])

        base_add(record.merge('status' => STATUS_REQUEUED))
      end

      def hash_name
        AttentiveSidekiq::REDIS_DISAPPEARED_KEY
      end
    end
  end

  class Suspicious < RedisBasedHash
    class << self
      def hash_name
        AttentiveSidekiq::REDIS_SUSPICIOUS_KEY
      end
    end
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
