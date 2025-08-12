
  id integer [primary key]
  resource_owner_id integer
  application_id integer
  token varchar
  refresh_token varchar
  expires_in integer
  revoked_at timestamp
  created_at timestamp
  scopes varchar
}

Table import_jobs {
  id integer [primary key]
  name varchar
  dry_run boolean
  payload text
  result text
  started_at timestamp
  finished_at timestamp
  created_at timestamp
  updated_at timestamp
}

// ... Add more tables as needed from migrations ...

// Relationships
Ref: users.organization_id > organizations.id
Ref: tickets.owner_id > users.id
Ref: tickets.customer_id > users.id
Ref: tickets.group_id > groups.id
Ref: articles.ticket_id > tickets.id
Ref: articles.sender_id > users.id
Ref: users.id < sessions.session_id
Ref: oauth_access_grants.application_id > oauth_applications.id
Ref: oauth_access_tokens.application_id > oauth_applications.id
Ref: oauth_access_grants.resource_owner_id > users.id
Ref: oauth_access_tokens.resource_owner_id > users.id
// ... Add more relationships as needed ...
