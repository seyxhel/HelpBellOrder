# Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/

Rails.application.configure do
  # config.action_cable.adapter = :redis # Removed: not supported in Rails 7+
  config.action_cable.url = ENV['REDIS_URL'] || 'redis://localhost:6379/0'
  
  # Allow requests from production domains
  config.action_cable.allowed_request_origins = [
    'https://help-bell-order.onrender.com',
    'http://localhost:3000',
    /http:\/\/localhost:\d+/,
    /https:\/\/.*\.onrender\.com/
  ]
  
  # Disable request origin checking in development
  config.action_cable.disable_request_forgery_protection = Rails.env.development?
end
