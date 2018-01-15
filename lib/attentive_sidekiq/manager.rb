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
      
      # Sidekiq might have been too fast finishing up a job that appeared in the suspicious list
      # but didn't make it to the active list, so that's a false-positive.
      # We need to get the new suspicious list again, and remove any lost jobs that are no longer there.
      # Those jobs that appeared in the first suspicious list, but not the second one were simply finished
      # quickly by Sidekiq before showing up as active by a worker.
      suspicious  = AttentiveSidekiq::Suspicious.jobs
      those_lost.delete_if{|i| !suspicious.include?(i["jid"])}
      
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
