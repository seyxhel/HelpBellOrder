// Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/

let aiAssistantTextTools = {
  popover: {
    base: '',
    item: '',
    button: '',
  },
  verticalGradient: '',
}

export const initializeAiAssistantTextToolsClasses = (classes: typeof aiAssistantTextTools) => {
  aiAssistantTextTools = classes
}

export const getAiAssistantTextToolsClasses = () => aiAssistantTextTools
