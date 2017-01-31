require "test_helper"

class ConfigTest < Minitest::Test
  def setup
    super
    @execution_interval, @timeout_interval = AttentiveSidekiq.options.values_at(:execution_interval, :timeout_interval)
    AttentiveSidekiq.instance_eval do remove_instance_variable(:@options) end
  end

  def teardown
    super
    AttentiveSidekiq.options.clear
    AttentiveSidekiq.options.merge!(execution_interval: @execution_interval, timeout_interval: @timeout_interval)
    Sidekiq.options.delete(:attentive)
    Sidekiq.options.delete('attentive')
    # Confirm the options were changed
    assert_equal default_timeout_interval, AttentiveSidekiq.timeout_interval
    assert_equal default_execution_interval, AttentiveSidekiq.execution_interval
  end

  def test_default_options
    expected_options = { execution_interval: default_execution_interval, timeout_interval: default_timeout_interval}
    assert_equal expected_options, AttentiveSidekiq.options.symbolize_keys
  end

  def test_default_execution_interval
    assert_equal default_execution_interval, AttentiveSidekiq.execution_interval
  end

  def test_default_timeout_interval
    assert_equal default_timeout_interval, AttentiveSidekiq.timeout_interval
  end

  def test_change_execution_interval
    new_execution_interval = default_execution_interval + 100
    AttentiveSidekiq.execution_interval = new_execution_interval
    assert_equal new_execution_interval, AttentiveSidekiq.execution_interval
  end

  def test_change_timeout_interval
    new_timeout_interval = default_timeout_interval + 100
    AttentiveSidekiq.timeout_interval = new_timeout_interval
    assert_equal new_timeout_interval, AttentiveSidekiq.timeout_interval
  end

  def test_change_execution_interval_via_sidekiq_options_with_string_key
    new_execution_interval = default_execution_interval + 100
    Sidekiq.options.delete(:attentive)
    Sidekiq.options['attentive'] = { 'execution_interval' => new_execution_interval }
    assert_equal new_execution_interval, AttentiveSidekiq.execution_interval
  end

  def test_change_execution_interval_via_sidekiq_options_with_symbol_key
    new_execution_interval = default_execution_interval + 100
    Sidekiq.options[:attentive] = {}
    Sidekiq.options[:attentive][:execution_interval] = new_execution_interval
    assert_equal new_execution_interval, AttentiveSidekiq.execution_interval
  end

  def test_change_timeout_interval_via_sidekiq_options_with_string_key
    new_timeout_interval = default_timeout_interval + 100
    Sidekiq.options.delete(:attentive)
    Sidekiq.options['attentive'] = { 'timeout_interval' => new_timeout_interval }
    assert_equal new_timeout_interval, AttentiveSidekiq.timeout_interval
  end

  def test_change_timeout_interval_via_sidekiq_options_with_symbol_key
    new_timeout_interval = default_timeout_interval + 100
    Sidekiq.options[:attentive] = {}
    Sidekiq.options[:attentive][:timeout_interval] = new_timeout_interval
    assert_equal new_timeout_interval, AttentiveSidekiq.timeout_interval
  end

  def test_middleware_without_options_set_default_values
    AttentiveSidekiq::Middleware::Server::Attentionist.new
    expected_options = { execution_interval: default_execution_interval, timeout_interval: default_timeout_interval}
    assert_equal expected_options, AttentiveSidekiq.options.symbolize_keys
  end

  def test_middleware_with_options
    new_execution_interval = default_execution_interval + 100
    new_timeout_interval = default_timeout_interval + 100
    expected_options = { execution_interval: new_execution_interval, timeout_interval: new_timeout_interval}
    AttentiveSidekiq::Middleware::Server::Attentionist.new(expected_options)
    assert_equal expected_options, AttentiveSidekiq.options.symbolize_keys
  end

  private

  def default_execution_interval
    AttentiveSidekiq::DEFAULTS.fetch(:execution_interval)
  end

  def default_timeout_interval
    AttentiveSidekiq::DEFAULTS.fetch(:timeout_interval)
  end
end
