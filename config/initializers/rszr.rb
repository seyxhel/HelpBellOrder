# Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/

#
# https://github.com/zammad/zammad/issues/4347
# This file will be removed along with lib/core_ext/rszr.rb
# When all supported Linux distributions update to >= 1.9 imlib2

begin
  require 'rszr'
  Rszr.autorotate = Rszr.needs_autorotate_fix?
rescue LoadError
  # Rszr gem not available - skip initialization
  Rails.logger.info "Rszr gem not available, skipping image processing features" if defined?(Rails.logger)
end
