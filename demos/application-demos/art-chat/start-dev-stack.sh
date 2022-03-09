#!/usr/bin/env bash

npm run dynamodb&
npm run lcp&
sleep 2
npm run init-dev
npm run start-dev-webserver&
wait