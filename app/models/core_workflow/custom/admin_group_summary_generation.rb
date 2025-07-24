# Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/

class CoreWorkflow::Custom::AdminGroupSummaryGeneration < CoreWorkflow::Custom::Backend
  def saved_attribute_match?
    selected_attribute_match?
  end

  def selected_attribute_match?
    object?(Group)
  end

  def perform
    result(visibility, 'summary_generation')
  end

  def visibility
    return 'show' if Setting.get('ai_provider').present?

    'remove'
  end
end
