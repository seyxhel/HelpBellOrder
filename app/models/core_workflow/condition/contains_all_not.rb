# Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/

class CoreWorkflow::Condition::ContainsAllNot < CoreWorkflow::Condition::Backend
  def match
    !value.intersect?(condition_value)
  end
end
