#!/usr/bin/env node

let dynamoLocalPort = 8081;

console.log(`Starting dynamodb on port ${dynamoLocalPort}`)
require('dynamodb-local').launch(dynamoLocalPort, null, ["-sharedDb", "-cors", '"*"'])
