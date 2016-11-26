module AttentiveSidekiq
  class Manager
    @@instance = AttentiveSidekiq::Manager.new
  
    def self.instance
      @@instance
    end
  
    def start!
      task = Concurrent::TimerTask.new(options) do
        AttentiveSidekiq::Manager.instance.update_disappeared_jobs
      end
      task.add_observer(AttentiveSidekiq::UpdaterObserver.new)
      task.execute
    end
    
    def update_disappeared_jobs
      suspicious  = AttentiveSidekiq::Suspicious.jobs
      active_ids  = AttentiveSidekiq::Active.job_ids
      those_lost  = suspicious.delete_if{|i| active_ids.include?(i["jid"])}
      those_lost.each do |job|
        Disappeared.add(job)
        Suspicious.remove(job['jid'])
      end
    end

    private_class_method :new
    
    private
    
    def options
      { 
        execution_interval: AttentiveSidekiq.execution_interval,
        timeout_interval: AttentiveSidekiq.timeout_interval
      }
    end
    
  end
end
