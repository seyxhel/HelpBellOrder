# Simple startup check to help debug deployment issues
Rails.application.config.after_initialize do
  begin
    Rails.logger.info "=== STARTUP CHECK BEGIN ==="
    Rails.logger.info "DATABASE_URL: #{ENV['DATABASE_URL']&.gsub(/:[^:@]*@/, ':***@')}"
    Rails.logger.info "REDIS_URL: #{ENV['REDIS_URL']&.gsub(/:[^:@]*@/, ':***@')}"
    
    # Test database connection with more details
    begin
      db_connected = ActiveRecord::Base.connection.active?
      Rails.logger.info "Database connection: #{db_connected}"
      Rails.logger.info "Database adapter: #{ActiveRecord::Base.connection.adapter_name}"
      Rails.logger.info "Database name: #{ActiveRecord::Base.connection.current_database}"
      
      # Try a direct query to force a real error
      result = ActiveRecord::Base.connection.execute('SELECT 1')
      Rails.logger.info "Database SELECT 1 result: #{result.inspect}"
    rescue => db_error
      Rails.logger.error "Database connection error: #{db_error.message}"
      Rails.logger.error "Database error class: #{db_error.class}"
      Rails.logger.error "Database error backtrace: #{db_error.backtrace.join("\n")}"
      raise db_error
    end
    
    # Test Redis connection
    begin
      redis_response = Redis.new(url: ENV['REDIS_URL'] || 'redis://localhost:6379').ping
      Rails.logger.info "Redis connection: #{redis_response}"
    rescue => redis_error
      Rails.logger.error "Redis connection error: #{redis_error.message}"
    end
    
    Rails.logger.info "Environment: #{Rails.env}"
    Rails.logger.info "=== STARTUP CHECK END ==="
  rescue => e
    Rails.logger.error "=== STARTUP CHECK FAILED: #{e.message} ==="
    Rails.logger.error e.backtrace.join("\n")
  end
end
