require "test_helper"

class ManagerTest < Minitest::Test
  describe "with real redis" do
    before do
      Sidekiq.redis = REDIS
      Sidekiq.redis{ |c| c.flushdb }

      common_hash       = {'class' => 'UnexistantWorker', 'args' => [], 'created_at' => Time.now.to_i}
      @item_in_progress = {'jid' => "REDA-257513", 'queue' => 'red_queue'}.merge!(common_hash)
      @item_disappeared = {'jid' => "YE11OW5-247", 'queue' => 'yellow_queue'}.merge!(common_hash)

      AttentiveSidekiq::Suspicious.add @item_in_progress
      AttentiveSidekiq::Suspicious.add @item_disappeared

      @active_job_ids = [@item_in_progress['jid']]
    end

    it "removes lone job from suspicious and adds to disappeared" do
      AttentiveSidekiq::Active.stub(:job_ids, @active_job_ids) do
        AttentiveSidekiq::Manager.instance.update_disappeared_jobs

        assert_includes disappeared_now, @item_disappeared
        refute_includes suspicious_now, @item_disappeared
      end
    end

    it "leaves jobs which are being currently processed in suspicious" do
      AttentiveSidekiq::Active.stub(:job_ids, @active_job_ids) do
        AttentiveSidekiq::Manager.instance.update_disappeared_jobs

        assert_includes suspicious_now, @item_in_progress
        refute_includes disappeared_now, @item_in_progress
      end
    end

    def suspicious_now
      Sidekiq.redis{|conn| conn.hvals(AttentiveSidekiq::REDIS_SUSPICIOUS_KEY)}.map{|i| JSON.parse(i)}
    end

    def disappeared_now
      from_redis = Sidekiq.redis{|conn| conn.hvals(AttentiveSidekiq::REDIS_DISAPPEARED_KEY)}
      from_redis.map{|i| JSON.parse(i).except('noticed_at', 'status')}
    end
  end
end
