Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add AttentiveSidekiq::Middleware::Server::Attentionist
  end
  config.client_middleware do |chain|
    chain.add AttentiveSidekiq::Middleware::Client::Attentionist
  end
end

Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add AttentiveSidekiq::Middleware::Client::Attentionist
  end
end
