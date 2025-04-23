#!/usr/bin/env bash

corepack enable pnpm

pnpm install --frozen-lockfile --ignore-scripts
pnpm cypress:install
pnpm test:ci:ct --env pluginVisualRegressionUpdateImages=$CYPRESS_UPDATE_SNAPSHOTS --spec '../../**/*-visuals.cy.*'
