// Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/

import { EnumSearchableModels } from '#shared/graphql/types.ts'

import TicketListTable from '#desktop/components/Ticket/TicketListTable.vue'

import Ticket from '../QuickSearch/entities/Ticket.vue'

import type { SearchPlugin } from '../types.ts'

export default <SearchPlugin>{
  name: EnumSearchableModels.Ticket,
  label: __('Ticket'),
  priority: 100,
  quickSearchResultLabel: __('Found tickets'),
  quickSearchComponent: Ticket,
  quickSearchResultKey: 'quickSearchTickets',
  permissions: ['ticket.agent', 'ticket.customer'],
  detailSearchHeaders: (config) => {
    const headers = [
      'stateIcon',
      'number',
      'title',
      'customer',
      'group',
      'owner',
      'created_at',
    ]

    if (config.ui_ticket_priority_icons) {
      headers.unshift('priorityIcon')
    }

    return headers
  },
  detailSearchComponent: TicketListTable,
}
