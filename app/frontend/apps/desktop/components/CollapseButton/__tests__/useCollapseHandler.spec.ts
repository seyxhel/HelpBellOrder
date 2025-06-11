// Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/

import { mount } from '@vue/test-utils'
import { beforeEach, vi } from 'vitest'
import { nextTick } from 'vue'

import { useCollapseHandler } from '#desktop/components/CollapseButton/useCollapseHandler.ts'

describe('useCollapseHandler', () => {
  const emit = vi.fn()

  beforeEach(() => {
    localStorage.clear()
  })

  it('sync local storage state on initial load', async () => {
    localStorage.setItem('test', 'true')
    const TestComponent = {
      setup() {
        const { isCollapsed } = useCollapseHandler(emit, { storageKey: 'test' })
        expect(isCollapsed.value).toBe(true)
      },
      template: '<div></div>',
    }
    mount(TestComponent)
    expect(emit).toHaveBeenCalledWith('collapse', true)
  })

  it('sync local storage state on subsequent mutations', async () => {
    localStorage.setItem('test', 'true')
    const TestComponent = {
      setup() {
        const { isCollapsed } = useCollapseHandler(emit, { storageKey: 'test' })
        expect(isCollapsed.value).toBe(true)
      },
      template: '<div></div>',
    }
    mount(TestComponent)
    expect(emit).toHaveBeenCalled()
    localStorage.setItem('test', 'false')
    expect(emit).toHaveBeenCalled()
  })

  it('calls expand if collapse state is false', async () => {
    const TestComponent = {
      setup() {
        const { toggleCollapse } = useCollapseHandler(emit, {
          storageKey: 'test',
        })
        toggleCollapse()
      },
      template: '<div></div>',
    }

    mount(TestComponent)
    await nextTick()
    expect(emit).toHaveBeenCalledWith('collapse', true)
  })
})
