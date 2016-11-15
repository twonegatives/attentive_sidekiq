module AttentiveSidekiq
  class DisappearedSet
    attr_accessor :jobs, :job_ids
    def initialize 
      suspicious  = AttentiveSidekiq::SuspiciousSet.new.jobs
      active_ids  = AttentiveSidekiq::ActiveSet.new.job_ids
      @jobs       = suspicious.delete_if{|i| active_ids.include?(i["jid"])}
      @job_ids    = @jobs.map{|i| i["jid"]}
    end

    private
    def clear
      # TODO
    end

    def remove jid
      # TODO
    end
  end
  
  class SuspiciousSet
    attr_accessor :jobs, :job_ids
    def initialize 
      @jobs     = Sidekiq.redis{|conn| conn.hvals(AttentiveSidekiq::Middleware::REDIS_KEY)}.map{|i| JSON.parse(i)}
      @job_ids  = @jobs.map{|i| i["jid"]}
    end

    private
    def clear
      # TODO
    end

    def remove jid
      # TODO
    end
  end

  class ActiveSet
    attr_accessor :jobs, :job_ids
    def initialize
      @jobs     = Sidekiq::Workers.new.to_a.map{|i| i[2]["payload"]}
      @job_ids  = Set.new(jobs.map{|i| i["jid"]})
    end
  end
end
