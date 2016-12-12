if Rails.env == "production"
  Sidekiq::Logging.logger.level = Logger::WARN
end

# TODO: Change uri by environment.
Sidekiq.configure_server do |config|
  config.redis = { url: "redis://192.168.33.10:6379" }
end
Sidekiq.configure_client do |config|
  config.redis = { url: "redis://192.168.33.10:6379" }
end
