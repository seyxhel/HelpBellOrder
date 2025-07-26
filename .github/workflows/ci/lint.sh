#!/usr/bin/env bash

set -o errexit
set -o pipefail

# shellcheck disable=SC1091
source /etc/profile.d/rvm.sh
# shellcheck disable=SC1091
source .gitlab/environment.env

echo "Checking .po file syntaxâ€¦"
for FILE in i18n/*.pot i18n/*.po; do echo "Checking $FILE"; msgfmt -o /dev/null -c "$FILE"; done
echo "Checking .pot catalog consistencyâ€¦"
bundle exec rails generate zammad:translation_catalog --check
echo "Brakeman security checkâ€¦"
bundle exec brakeman -o /dev/stdout -o tmp/brakeman-report.html
echo "Rails zeitwerk:check autoloader checkâ€¦"
bundle exec rails zeitwerk:check
.gitlab/check_graphql_api_consistency.sh
echo "Rubocop checkâ€¦"
bundle exec .dev/rubocop/validate_todos.rb
bundle exec rubocop --parallel
echo "Coffeelint checkâ€¦"
coffeelint --rules ./.dev/coffeelint/rules/* app/
echo "Type checkâ€¦"
pnpm lint:ts
echo "ESLint checkâ€¦"
pnpm lint:js
echo "Stylelint checkâ€¦"
pnpm lint:css
