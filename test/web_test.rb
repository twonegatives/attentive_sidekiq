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

    AttentiveSidekiq::Suspicious.add(@item_in_progress)
    AttentiveSidekiq::Disappeared.add(@item_disappeared)
  end

  def test_displays_jobs_in_disappeared_hash
    get '/disappeared-jobs'
    assert_equal 200, last_response.status
    assert_match @item_disappeared['jid'], last_response.body
  end

  def test_does_not_display_jobs_not_in_disappeared_hash
    get '/disappeared-jobs'
    assert_equal 200, last_response.status
    refute_match @item_in_progress['jid'], last_response.body
  end

  def test_delete_route_functions_fine
    AttentiveSidekiq::Disappeared.stub(:remove, nil) do
      post "/disappeared-jobs/#{@item_disappeared['jid']}/delete"
      follow_redirect!
      assert_equal 200, last_response.status
    end
  end

  def test_requeue_route_functions_fine
    AttentiveSidekiq::Disappeared.stub(:requeue, nil) do
      post "/disappeared-jobs/#{@item_disappeared['jid']}/requeue"
      follow_redirect!
      assert_equal 200, last_response.status
    end
  end

  private

  def app
    Sidekiq::Web
  end
end
