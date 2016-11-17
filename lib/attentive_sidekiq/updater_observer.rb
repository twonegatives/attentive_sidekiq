module AttentiveSidekiq
  class UpdaterObserver
    def update time, result, ex
      if result
        AttentiveSidekiq.logger.info("#{time} [AttentiveSidekiq] Finished updating with result #{result}")
      elsif ex.is_a?(Concurrent::TimeoutError)
        AttentiveSidekiq.logger.error("#{time} [AttentiveSidekiq] Execution timed out")
      else
        AttentiveSidekiq.logger.error("#{time } [AttentiveSidekiq] Execution failed with error #{ex}\n")
      end
    end
  end
end
