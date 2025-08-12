# Simple startup check to help debug deployment issues
Rails.application.config.after_initialize do
  begin
    Rails.logger.info "=== STARTUP CHECK BEGIN ==="
    Rails.logger.info "Database connection: #{ActiveRecord::Base.connection.active?}"
    Rails.logger.info "Redis connection: #{Redis.new(url: ENV['REDIS_URL'] || 'redis://localhost:6379').ping}"
    Rails.logger.info "Environment: #{Rails.env}"
    Rails.logger.info "=== STARTUP CHECK END ==="
  rescue => e
    Rails.logger.error "=== STARTUP CHECK FAILED: #{e.message} ==="
    Rails.logger.error e.backtrace.join("\n")
  end
end
