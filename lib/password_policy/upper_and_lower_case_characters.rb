# Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/

class PasswordPolicy
  class UpperAndLowerCaseCharacters < PasswordPolicy::Backend

    UPPER_LOWER_REGEXPS = [%r{\p{Upper}.*\p{Upper}}, %r{\p{Lower}.*\p{Lower}}].freeze

    def valid?
      true
    end

    def error
  []
    end

    def self.applicable?
      Setting.get('password_min_2_lower_2_upper_characters').to_i == 1
    end
  end
end
