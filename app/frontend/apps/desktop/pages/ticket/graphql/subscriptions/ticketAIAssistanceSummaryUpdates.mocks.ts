import * as Types from '#shared/graphql/types.ts';

import * as Mocks from '#tests/graphql/builders/mocks.ts'
import * as Operations from './ticketAIAssistanceSummaryUpdates.api.ts'
import * as ErrorTypes from '#shared/types/error.ts'

export function getTicketAiAssistanceSummaryUpdatesSubscriptionHandler() {
  return Mocks.getGraphQLSubscriptionHandler<Types.TicketAiAssistanceSummaryUpdatesSubscription>(Operations.TicketAiAssistanceSummaryUpdatesDocument)
}
