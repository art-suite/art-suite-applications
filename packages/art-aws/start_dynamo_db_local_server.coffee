#!/usr/bin/env coffee
DynamoDbLocal = require 'dynamodb-local'

dynamoLocalPort = 8081
DynamoDbLocal.launch dynamoLocalPort, null, ["-sharedDb", "-cors", '"*"'] #if you want to share with Javascript Shell
#Do your tests
#shell: http://localhost:8081/shell/
#DynamoDbLocal.stop(dynamoLocalPort);
