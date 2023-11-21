#!/usr/bin/env bash
VERSION=5.6.2
DIR=`pwd`/`dirname "$0"`/devserver
PIDFILE=$DIR/elasticsearch.pid
INSTALLDIR=$DIR/elasticsearch-$VERSION/
echo DIR $DIR
echo PIDFILE $PIDFILE
echo INSTALLDIR $INSTALLDIR

if [ -f "$PIDFILE" ]
then
  echo pwd `pwd`
  PID=`cat $PIDFILE`
  echo "ELASTICSEARCH: stopping old server"
  echo "ELASTICSEARCH: kill $PID"
  kill $PID
  sleep .5
  echo "ELASTICSEARCH: any old servers still running?"
  ps aux | grep -i "java.*[e]lasticsearch"
  echo ""
fi

echo "ELASTICSEARCH: deleting old data: $INSTALLDIR"
rm -rf $INSTALLDIR
echo "ELASTICSEARCH: unzipping v$VERSION"
unzip $DIR/elasticsearch-$VERSION.zip -d $DIR> /dev/null
echo "ELASTICSEARCH: starting server v$VERSION with PIDFILE $PIDFILE"
rm $PIDFILE
$INSTALLDIR/bin/elasticsearch -d -p $PIDFILE

while [ ! -f "$PIDFILE" ]
do
  sleep 1
  echo "ELASTICSEARCH: waiting for server to start..."
done
echo "ELASTICSEARCH: ready!"