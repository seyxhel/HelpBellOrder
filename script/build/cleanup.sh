#!/bin/bash

set -eu  # Remove 'x' flag to reduce verbose output

# Use || true to prevent script from failing if files don't exist
rm -f app/assets/javascripts/app/controllers/layout_ref.coffee || true
rm -rf app/assets/javascripts/app/views/layout_ref/ || true

# tests
rm -rf test spec app/frontend/tests app/frontend/cypress || true
find app/frontend/ -type d -name __tests__ -exec rm -rf {} + 2>/dev/null || true
rm -f .rspec || true

# CI
rm -rf .github .gitlab || true
rm -f .gitlab-ci.yml || true

# linting
rm -f .rubocop.yml || true
rm -f .stylelintrc.json .oxlintrc.json eslint.config.ts .prettierrc.json || true
rm -f coffeelint.json || true
rm -f .overcommit.* || true

# Yard
rm -f .yardopts || true

# developer manual
rm -rf doc/developer_manual || true

# Various development files
rm -rf .dev .devcontainer || true

# delete caches
rm -rf tmp/* || true

# Delete node_modules folder - only required during building
rm -rf node_modules || true
