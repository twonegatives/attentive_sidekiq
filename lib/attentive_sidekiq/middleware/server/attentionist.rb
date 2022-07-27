module AttentiveSidekiq
  module Middleware
    module Server
      class Attentionist
        def call(worker_instance, item, queue)
          reliable_job = item["adblock_reliable"]

          if reliable_job
            AttentiveSidekiq.logger.info("AttentiveSidekiq will monitor job: #{item}")
            Suspicious.add(item)
          end

          yield
        ensure
          Suspicious.remove(item['jid']) if reliable_job
        end
      end
    end
  end
end
