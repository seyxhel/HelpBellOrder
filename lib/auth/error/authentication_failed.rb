# Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/

class Auth::Error::AuthenticationFailed < Auth::Error::Base
  MESSAGE = __('Invalid credentials.')

  def message
    MESSAGE
  end
end
