require "test_helper"
require "rack/test"

class WebTest < Minitest::Test
  include Rack::Test::Methods

  def setup
    Sidekiq.redis = REDIS
    Sidekiq.redis{ |c| c.flushdb }

    common_hash       = {'class' => 'UnexistantWorker', 'args' => [], 'created_at' => Time.now.to_i}
    @item_disappeared = {'jid' => "YE11OW5-247", 'queue' => 'yellow_queue'}.merge!(common_hash)
    @item_in_progress = {'jid' => "REDA-257513", 'queue' => 'red_queue'}.merge!(common_hash)

    add_item_to_suspicious @item_in_progress
    add_item_to_suspicious @item_disappeared
  end

  def test_displays_jobs_started_but_not_processing
    get '/disappeared-jobs'
    assert_equal 200, last_response.status
    assert_match @item_disappeared['jid'], last_response.body
  end

  def test_does_not_display_jobs_started_and_processing
    stubbed_payload = [[nil, nil, {'payload' => {'jid' => @item_in_progress['jid']}}]]
    Sidekiq::Workers.stub :new, stubbed_payload do
      get '/disappeared-jobs'
      assert_equal 200, last_response.status
      refute_match @item_in_progress['jid'], last_response.body
    end
  end

  private

  def app
    Sidekiq::Web
  end
 
  def add_item_to_suspicious item
    Sidekiq.redis{ |conn| conn.hset(AttentiveSidekiq::Middleware::REDIS_KEY, item['jid'], item.to_json) }
  end
end
