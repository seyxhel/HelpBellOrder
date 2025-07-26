﻿#!/usr/bin/env bash

set -o errexit
set -o pipefail

# shellcheck disable=SC1091
source /etc/profile.d/rvm.sh
# shellcheck disable=SC1091
source .gitlab/environment.env

echo "Checking assets generationâ€¦"
bundle exec rake assets:precompile

echo "Running front end testsâ€¦"
pnpm test

echo "Running basic rspec testsâ€¦"
bundle exec rake zammad:db:init
bundle exec rspec --exclude-pattern "spec/system/**/*_spec.rb" -t ~searchindex -t ~integration -t ~required_envs

echo "Running basic minitest testsâ€¦"
bundle exec rake zammad:db:reset
bundle exec rake test:units
