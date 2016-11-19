require "test_helper"

class ApiTest < Minitest::Test
  describe "with real redis" do
    before do
      Sidekiq.redis = REDIS
      Sidekiq.redis{ |c| c.flushdb }

      simple_hash             = {'class' => 'ApiTest::SimpleWorker', 'args' => [], 'created_at' => Time.now.to_i}
      args_hash               = {'args' => [1, "boo", "woo"], 'class' => 'ApiTest::WorkerWithArgs', 'created_at' => Time.now.to_i}

      @item_in_progress       = {'jid' => "REDA-257513", 'queue' => 'red_queue'}.merge!(simple_hash)
      @disappeared_wo_args    = {'jid' => "YE11OW5-247", 'queue' => 'yellow_queue'}.merge!(simple_hash)
      @disappeared_with_args  = {'jid' => "B1UE-441", 'queue' => 'blue_queue'}.merge!(args_hash)

      AttentiveSidekiq::Suspicious.add(@item_in_progress)

      AttentiveSidekiq::Disappeared.add(@disappeared_wo_args)
      AttentiveSidekiq::Disappeared.add(@disappeared_with_args)
    end

    class BaseWorker
      include Sidekiq::Worker
    end

    class SimpleWorker < BaseWorker
      def perform
      end
    end

    class WorkerWithArgs < BaseWorker
      def perform a, b, c
      end
    end

    describe "requeue" do
      it "adds jobs without args to sidekiq queue" do
        item = @disappeared_wo_args
        assert_equal 0, Sidekiq::Queue.new.size
        String.stub_any_instance("constantize", SimpleWorker) do
          AttentiveSidekiq::Disappeared.requeue(item['jid'])
        end
        assert_equal 1, Sidekiq::Queue.new.size
        element = Sidekiq::Queue.new.to_a.first
        assert_equal item['class'], element['class']
        assert_equal item['args'], element['args']
      end

      it "adds job with args to sidekiq queue" do
        item = @disappeared_with_args
        String.stub_any_instance("constantize", WorkerWithArgs) do
          AttentiveSidekiq::Disappeared.requeue(item['jid'])
        end
        element = Sidekiq::Queue.new.to_a.first
        assert_equal item['class'], element['class']
        assert_equal item['args'], element['args']
      end

      it "marks jobs as requeued" do
        item = @disappeared_wo_args
        assert_equal job_status(item), AttentiveSidekiq::Disappeared::STATUS_DETECTED
        String.stub_any_instance("constantize", SimpleWorker) do
          AttentiveSidekiq::Disappeared.requeue(item['jid'])
        end
        assert_equal job_status(item), AttentiveSidekiq::Disappeared::STATUS_REQUEUED
      end

      def job_status(item)
        AttentiveSidekiq::Disappeared.get_job(item['jid'])['status']
      end
    end
  end
end
