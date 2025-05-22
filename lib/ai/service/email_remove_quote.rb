# Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/

class AI::Service::EmailRemoveQuote < AI::Service
  def self.persistent_lookup_attributes(context_data, _locale)
    {
      identifier:     'article-email-remove-quoted',
      related_object: context_data[:article],
    }
  end

  def self.persistent_version(_context_data, _locale)
    nil
  end

  private

  def options
    {
      temperature: 0,
    }
  end

  def persistable?
    true
  end
end
