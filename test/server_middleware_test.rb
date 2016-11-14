require "test_helper"

class ServerMiddlewareTest < Minitest::Test
  describe "with real redis" do
    before do
      Sidekiq.redis = REDIS
      Sidekiq.redis{ |c| c.flushdb }

      @mutex = Mutex.new
      @stopper = ConditionVariable.new
    end

    class HardWorker
      include Sidekiq::Worker

      def perform(seed, work_amount = 10)
        raise "wrong amount of work" if work_amount <= 0
        1.upto(work_amount) do |i|
          1.upto(work_amount) do |j|
            1.upto(work_amount) do |k|
              i*j*k
            end
          end
        end
      end
    end

    class SidekiqEmulator
      @@instance = SidekiqEmulator.new

      def self.instance
        @@instance
      end

      def process_jobs
        processor.send(:process, work_unit)
      end

      private_class_method :new

      private

      def processor
        ::Sidekiq::Processor.new(manager)
      end

      def manager
        options = { :concurrency => 1, :queues => ['default'] }
        Sidekiq::Manager.new(options)
      end
      
      def work_unit
        fetch = Sidekiq::BasicFetch.new(:queues => ['default'])
        fetch.retrieve_work
      end

    end

    class DefaultQueue
      @@instance = DefaultQueue.new
      
      def self.instance
        @@instance
      end

      def size
        queue.size rescue 0
      end

      def queue
        ::Sidekiq::Queue.new
      end

      private_class_method :new
    end

    it "does not mark job as suspicious while its queued" do
      assert_equal 0, DefaultQueue.instance.size
      HardWorker.perform_async(1)
      assert_equal 1, DefaultQueue.instance.size
      assert_equal 0, Sidekiq.redis{|conn| conn.hvals(AttentiveSidekiq::Middleware::REDIS_KEY)}.size
    end

    it "marks job as suspicious as soon as it is started" do
      assert_equal 0, Sidekiq.redis{|conn| conn.hvals(AttentiveSidekiq::Middleware::REDIS_KEY)}.size
      HardWorker.perform_async(2, 100_000)
      Thread.new{
        SidekiqEmulator.instance.process_jobs
      }
      sleep(1) # TODO: refactor this somehow
      assert_equal 1, Sidekiq.redis{|conn| conn.hvals(AttentiveSidekiq::Middleware::REDIS_KEY)}.size
    end

    it "removes suspicious mark as soon as job is finished succesfully" do
      assert_equal 0, Sidekiq.redis{|conn| conn.hvals(AttentiveSidekiq::Middleware::REDIS_KEY)}.size
      HardWorker.perform_async(2, 1)
      Thread.new{
        @mutex.synchronize{
          SidekiqEmulator.instance.process_jobs
          @stopper.signal
        }
      }
      @mutex.synchronize{ @stopper.wait(@mutex) }
      assert_equal 0, Sidekiq.redis{|conn| conn.hvals(AttentiveSidekiq::Middleware::REDIS_KEY)}.size
    end

    it "removes suspicious mark as soon as job failed" do
      assert_equal 0, Sidekiq.redis{|conn| conn.hvals(AttentiveSidekiq::Middleware::REDIS_KEY)}.size
      HardWorker.perform_async(2, -1)
      Thread.new{
        @mutex.synchronize{
          SidekiqEmulator.instance.process_jobs rescue nil
          @stopper.signal
        }
      }
      @mutex.synchronize{ @stopper.wait(@mutex) }
      assert_equal 0, Sidekiq.redis{|conn| conn.hvals(AttentiveSidekiq::Middleware::REDIS_KEY)}.size
    end
  end
end
