require 'sidekiq'
require 'sidekiq/web'

queues = [:critical, :default, :low, 'default-demo-queue']

Sidekiq.configure_server do |config|
  config.options[:queues] = queues
  config.redis = { url: "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}", namespace: "#{ENV['SIDEKIQ_NAMESPACE']}/queue" }
end

Sidekiq.configure_client do |config|
  config.options[:queues] = queues
  config.redis = { url: "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}", namespace: "#{ENV['SIDEKIQ_NAMESPACE']}/queue" }

end

Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  [user, password] == ['sidekiq', 'sidekiq']
end
