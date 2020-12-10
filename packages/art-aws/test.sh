nn -s
./start_dynamo_db_local_server&
PID=$!
echo PID=$!
mocha -u tdd
SUCCESS=$?
kill $PID
exit $SUCCESS