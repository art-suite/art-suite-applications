#! /usr/bin/env bash
curl \
  --header 'Accept:*/*'\
  --header 'Accept-Encoding:gzip, deflate'\
  --header 'Accept-Language:en-US,en;q=0.8'\
  --header 'Authorization:AWS4-HMAC-SHA256 Credential=thisIsSomeInvalidKey/20160907/us-east-1/dynamodb/aws4_request, SignedHeaders=host;x-amz-content-sha256;x-amz-date;x-amz-target;x-amz-user-agent, Signature=0777b525b623ee5e4cd7e11c31d46a4c5a6ea6dfb0cd5fcfcc937847225bb331'\
  --header 'Cache-Control:no-cache'\
  --header 'Connection:keep-alive'\
  --header 'Content-Length:188'\
  --header 'Content-Type:application/x-amz-json-1.0'\
  --header 'Host:localhost:8081'\
  --header 'Origin:http://localhost:8080'\
  --header 'Pragma:no-cache'\
  --header 'Referer:http://localhost:8080/app?dev=true'\
  --header 'User-Agent:Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.116 Safari/537.36'\
  --header 'X-Amz-Content-Sha256:216ca6ec1fc8306ed101f9418bc7f0ab51cc1352e65a18499a229dc221c01e8d'\
  --header 'X-Amz-Date:20160907T232444Z'\
  --header 'X-Amz-Target:DynamoDB_20120810.Query'\
  --header 'X-Amz-User-Agent:aws-sdk-js/2.4.6'\
  -X POST -d '{"TableName":"topic","IndexName":"topicsByUserId","ExpressionAttributeNames":{"#attr1":"userId"},"ExpressionAttributeValues":{":val1":{"S":""}},"KeyConditionExpression":"(#attr1 = :val1)"}' \
  http://localhost:8081/
