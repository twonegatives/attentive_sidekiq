require 'attentive_sidekiq/server/attentionist'
require 'attentive_sidekiq/client/attentionist'
require 'attentive_sidekiq/middleware'

class AttentiveSidekiq
  def self.hi
    puts "hello world!"
  end
end
