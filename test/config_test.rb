require "test_helper"

class ConfigTest < Minitest::Test
  SIDEKIQ_OPTIONS = Sidekiq.options

  def teardown
    super
    Sidekiq.options = SIDEKIQ_OPTIONS
    execution_interval = default_timeout_interval
    timeout_interval = default_timeout_interval
    AttentiveSidekiq.instance_eval do
      remove_instance_variable(:@execution_interval) if defined?(@execution_interval)
      remove_instance_variable(:@timeout_interval) if defined?(@timeout_interval)
    end
    # Confirm the instance variables were changed
    assert_equal default_timeout_interval, AttentiveSidekiq.timeout_interval
    assert_equal default_execution_interval, AttentiveSidekiq.execution_interval
  end

  def test_default_sidekiq_options
    assert_equal SIDEKIQ_OPTIONS, Sidekiq.options
    assert_equal Hash.new, AttentiveSidekiq.options
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
    Sidekiq.options['attentive'] = {}
    Sidekiq.options['attentive'][:execution_interval] = new_execution_interval
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
    Sidekiq.options['attentive'] = {}
    Sidekiq.options['attentive'][:timeout_interval] = new_timeout_interval
    assert_equal new_timeout_interval, AttentiveSidekiq.timeout_interval
  end

  def test_change_timeout_interval_via_sidekiq_options_with_symbol_key
    new_timeout_interval = default_timeout_interval + 100
    Sidekiq.options[:attentive] = {}
    Sidekiq.options[:attentive][:timeout_interval] = new_timeout_interval
    assert_equal new_timeout_interval, AttentiveSidekiq.timeout_interval
  end

  private

  def default_execution_interval
    AttentiveSidekiq::DEFAULTS.fetch(:execution_interval)
  end

  def default_timeout_interval
    AttentiveSidekiq::DEFAULTS.fetch(:timeout_interval)
  end
end
