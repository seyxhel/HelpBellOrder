import * as Types from '#shared/graphql/types.ts';

import gql from 'graphql-tag';
export const OverviewAttributesFragmentDoc = gql`
    fragment overviewAttributes on Overview {
  id
  internalId
  name
  link
  prio
  groupBy
  orderBy
  orderDirection
  organizationShared
  outOfOffice
  active
  ticketCount @include(if: $withTicketCount)
}
    `;