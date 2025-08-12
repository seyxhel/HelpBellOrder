// Zammad Full Database Structure (DBML)
// Docs: https://dbml.dbdiagram.io/docs

Table users {
  id integer [primary key]
  organization_id integer
  login varchar
  firstname varchar
  lastname varchar
  email varchar
  image varchar
  image_source varchar
  web varchar
  password varchar
  phone varchar
  fax varchar
  mobile varchar
  department varchar
  street varchar
  zip varchar
  city varchar
  country varchar
  address varchar
  vip boolean
  verified boolean
  active boolean
  note varchar
  last_login timestamp
  source varchar
  login_failed integer
  out_of_office boolean
  out_of_office_start_at date
  out_of_office_end_at date
  out_of_office_replacement_id integer
  created_at timestamp
  updated_at timestamp
}

Table organizations {
  id integer [primary key]
  name varchar
  shared boolean
  domain varchar
  domain_assignment boolean
  active boolean
  vip boolean
  note varchar
  updated_by_id integer
  created_by_id integer
  created_at timestamp
  updated_at timestamp
}

Table groups {
  id integer [primary key]
  signature_id integer
  email_address_id integer
  name varchar
  name_last varchar
  parent_id integer
  assignment_timeout integer
  follow_up_possible varchar
  reopen_time_in_days integer
  follow_up_assignment boolean
  active boolean
  shared_drafts boolean
  summary_generation varchar
  note varchar
  updated_by_id integer
  created_by_id integer
  created_at timestamp
  updated_at timestamp
}

Table tickets {
  id integer [primary key]
  group_id integer
  owner_id integer
  customer_id integer
  state_id integer
  priority_id integer
  organization_id integer
  number varchar
  title varchar
  created_by_id integer
  updated_by_id integer
  created_at timestamp
  updated_at timestamp
}

Table articles {
  id integer [primary key]
  ticket_id integer
  sender_id integer
  type_id integer
  subject varchar
  body text
  created_by_id integer
  updated_by_id integer
  origin_by_id integer
  created_at timestamp
  updated_at timestamp
}

Table roles {
  id integer [primary key]
  name varchar
  preferences text
  default_at_signup boolean
  active boolean
  note varchar
  updated_by_id integer
  created_by_id integer
  created_at timestamp
  updated_at timestamp
}

Table sessions {
  session_id varchar [primary key]
  persistent boolean
  data text
  created_at timestamp
  updated_at timestamp
}

Table oauth_applications {
  id integer [primary key]
  name varchar
  uid varchar
  secret varchar
  redirect_uri text
  scopes varchar
  created_at timestamp
  updated_at timestamp
}

Table oauth_access_grants {
  id integer [primary key]
  resource_owner_id integer
  application_id integer
  token varchar
  expires_in integer
  redirect_uri text
  created_at timestamp
  revoked_at timestamp
  scopes varchar
}

Table oauth_access_tokens {
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

Table permissions {
  id integer [primary key]
  name varchar
  label varchar
  description varchar
  preferences text
  active boolean
  allow_signup boolean
  created_at timestamp
  updated_at timestamp
}

Table roles_users {
  user_id integer
  role_id integer
}

Table groups_users {
  user_id integer
  group_id integer
}

Table permissions_roles {
  role_id integer
  permission_id integer
}

Table signatures {
  id integer [primary key]
  name varchar
  body text
  active boolean
  note varchar
  updated_by_id integer
  created_by_id integer
  created_at timestamp
  updated_at timestamp
}

Table email_addresses {
  id integer [primary key]
  channel_id integer
  name varchar
  email varchar
  active boolean
  note varchar
  preferences text
  updated_by_id integer
  created_by_id integer
  created_at timestamp
  updated_at timestamp
}

Table settings {
  id integer [primary key]
  name varchar
  value text
  area varchar
  preferences text
  created_at timestamp
  updated_at timestamp
}

Table histories {
  id integer [primary key]
  history_type_id integer
  history_object_id integer
  history_attribute_id integer
  value_old text
  value_new text
  created_by_id integer
  created_at timestamp
}

Table stores {
  id integer [primary key]
  store_object_id integer
  store_file_id integer
  created_by_id integer
  created_at timestamp
}

Table avatars {
  id integer [primary key]
  user_id integer
  image varchar
  created_by_id integer
  updated_by_id integer
  created_at timestamp
  updated_at timestamp
}

Table calendars {
  id integer [primary key]
  name varchar
  created_by_id integer
  updated_by_id integer
  created_at timestamp
  updated_at timestamp
}

Table chat_sessions {
  id integer [primary key]
  chat_id integer
  user_id integer
  created_by_id integer
  updated_by_id integer
  created_at timestamp
  updated_at timestamp
}

Table chat_messages {
  id integer [primary key]
  chat_session_id integer
  created_by_id integer
  created_at timestamp
}

Table macros {
  id integer [primary key]
  name varchar
  created_by_id integer
  updated_by_id integer
  created_at timestamp
  updated_at timestamp
}

Table triggers {
  id integer [primary key]
  name varchar
  created_by_id integer
  updated_by_id integer
  created_at timestamp
  updated_at timestamp
}

Table templates {
  id integer [primary key]
  name varchar
  created_by_id integer
  updated_by_id integer
  created_at timestamp
  updated_at timestamp
}

Table channels {
  id integer [primary key]
  name varchar
  group_id integer
  created_by_id integer
  updated_by_id integer
  created_at timestamp
  updated_at timestamp
}

Table text_modules {
  id integer [primary key]
  name varchar
  body text
  created_by_id integer
  updated_by_id integer
  created_at timestamp
  updated_at timestamp
}

Table overviews {
  id integer [primary key]
  name varchar
  created_by_id integer
  updated_by_id integer
  created_at timestamp
  updated_at timestamp
}

Table jobs {
  id integer [primary key]
  name varchar
  created_by_id integer
  updated_by_id integer
  created_at timestamp
  updated_at timestamp
}

Table slas {
  id integer [primary key]
  name varchar
  created_by_id integer
  updated_by_id integer
  created_at timestamp
  updated_at timestamp
}

Table karma_users {
  id integer [primary key]
  user_id integer
  created_at timestamp
}

Table karma_activity_logs {
  id integer [primary key]
  user_id integer
  activity_id integer
  created_at timestamp
}

Table templates_groups {
  template_id integer
  group_id integer
}

Table text_modules_groups {
  text_module_id integer
  group_id integer
}

Table chat_agents {
  id integer [primary key]
  user_id integer
  created_by_id integer
  updated_by_id integer
  created_at timestamp
  updated_at timestamp
}

Table report_profiles {
  id integer [primary key]
  name varchar
  created_by_id integer
  updated_by_id integer
  created_at timestamp
  updated_at timestamp
}

Table ticket_time_accountings {
  id integer [primary key]
  ticket_id integer
  ticket_article_id integer
  created_by_id integer
  created_at timestamp
}

Table ticket_flags {
  id integer [primary key]
  ticket_id integer
  created_by_id integer
  created_at timestamp
}

Table ticket_article_flags {
  id integer [primary key]
  ticket_article_id integer
  created_by_id integer
  created_at timestamp
}

Table ticket_article_types {
  id integer [primary key]
  name varchar
  created_by_id integer
  updated_by_id integer
  created_at timestamp
  updated_at timestamp
}

Table ticket_article_senders {
  id integer [primary key]
  name varchar
  created_by_id integer
  updated_by_id integer
  created_at timestamp
  updated_at timestamp
}

Table ticket_priorities {
  id integer [primary key]
  name varchar
  default_create boolean
  ui_icon varchar
  ui_color varchar
  note varchar
  active boolean
  updated_by_id integer
  created_by_id integer
  created_at timestamp
  updated_at timestamp
}

Table ticket_states {
  id integer [primary key]
  state_type_id integer
  name varchar
  next_state_id integer
  ignore_escalation boolean
  default_create boolean
  default_follow_up boolean
  note varchar
  active boolean
  updated_by_id integer
  created_by_id integer
  created_at timestamp
  updated_at timestamp
}

Table ticket_state_types {
  id integer [primary key]
  name varchar
  note varchar
  updated_by_id integer
  created_by_id integer
  created_at timestamp
  updated_at timestamp
}

Table chats {
  id integer [primary key]
  name varchar
  created_by_id integer
  updated_by_id integer
  created_at timestamp
  updated_at timestamp
}

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
Ref: users.out_of_office_replacement_id > users.id
Ref: organizations.created_by_id > users.id
Ref: organizations.updated_by_id > users.id
Ref: groups.signature_id > signatures.id
Ref: groups.email_address_id > email_addresses.id
Ref: groups.parent_id > groups.id
Ref: groups.created_by_id > users.id
Ref: groups.updated_by_id > users.id
Ref: roles.created_by_id > users.id
Ref: roles.updated_by_id > users.id
Ref: roles_users.user_id > users.id
Ref: roles_users.role_id > roles.id
Ref: groups_users.user_id > users.id
Ref: groups_users.group_id > groups.id
Ref: permissions_roles.role_id > roles.id
Ref: permissions_roles.permission_id > permissions.id
Ref: tickets.organization_id > organizations.id
Ref: tickets.created_by_id > users.id
Ref: tickets.updated_by_id > users.id
Ref: articles.created_by_id > users.id
Ref: articles.updated_by_id > users.id
Ref: articles.origin_by_id > users.id
Ref: signatures.created_by_id > users.id
Ref: signatures.updated_by_id > users.id
Ref: email_addresses.created_by_id > users.id
Ref: email_addresses.updated_by_id > users.id
Ref: histories.created_by_id > users.id
Ref: stores.created_by_id > users.id
Ref: avatars.user_id > users.id
Ref: avatars.created_by_id > users.id
Ref: avatars.updated_by_id > users.id
Ref: calendars.created_by_id > users.id
Ref: calendars.updated_by_id > users.id
Ref: chat_sessions.chat_id > chats.id
Ref: chat_sessions.user_id > users.id
Ref: chat_sessions.created_by_id > users.id
Ref: chat_sessions.updated_by_id > users.id
Ref: chat_messages.chat_session_id > chat_sessions.id
Ref: chat_messages.created_by_id > users.id
Ref: macros.created_by_id > users.id
Ref: macros.updated_by_id > users.id
Ref: triggers.created_by_id > users.id
Ref: triggers.updated_by_id > users.id
Ref: templates.created_by_id > users.id
Ref: templates.updated_by_id > users.id
Ref: channels.group_id > groups.id
Ref: channels.created_by_id > users.id
Ref: channels.updated_by_id > users.id
Ref: text_modules.created_by_id > users.id
Ref: text_modules.updated_by_id > users.id
Ref: overviews.created_by_id > users.id
Ref: overviews.updated_by_id > users.id
Ref: jobs.created_by_id > users.id
Ref: jobs.updated_by_id > users.id
Ref: slas.created_by_id > users.id
Ref: slas.updated_by_id > users.id
Ref: karma_users.user_id > users.id
Ref: karma_activity_logs.user_id > users.id
Ref: templates_groups.template_id > templates.id
Ref: templates_groups.group_id > groups.id
Ref: text_modules_groups.text_module_id > text_modules.id
Ref: text_modules_groups.group_id > groups.id
Ref: chat_agents.user_id > users.id
Ref: chat_agents.created_by_id > users.id
Ref: chat_agents.updated_by_id > users.id
Ref: report_profiles.created_by_id > users.id
Ref: report_profiles.updated_by_id > users.id
Ref: ticket_time_accountings.ticket_id > tickets.id
Ref: ticket_time_accountings.ticket_article_id > articles.id
Ref: ticket_time_accountings.created_by_id > users.id
Ref: ticket_flags.ticket_id > tickets.id
Ref: ticket_flags.created_by_id > users.id
Ref: ticket_article_flags.ticket_article_id > articles.id
Ref: ticket_article_flags.created_by_id > users.id
Ref: ticket_article_types.created_by_id > users.id
Ref: ticket_article_types.updated_by_id > users.id
Ref: ticket_article_senders.created_by_id > users.id
Ref: ticket_article_senders.updated_by_id > users.id
Ref: ticket_priorities.created_by_id > users.id
Ref: ticket_priorities.updated_by_id > users.id
Ref: ticket_states.state_type_id > ticket_state_types.id
Ref: ticket_states.next_state_id > ticket_states.id
Ref: ticket_states.created_by_id > users.id
Ref: ticket_states.updated_by_id > users.id
Ref: ticket_state_types.created_by_id > users.id
Ref: ticket_state_types.updated_by_id > users.id
