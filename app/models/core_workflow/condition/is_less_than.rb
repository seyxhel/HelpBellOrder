# Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/

class CoreWorkflow::Condition::IsLessThan < CoreWorkflow::Condition::BaseOperator
  def check_operator
    :<
  end
end
