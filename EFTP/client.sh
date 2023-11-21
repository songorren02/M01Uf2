#!/bin/bash

IP=`ip address | grep inet | grep enp0s3 | cut -c 10-19`

echo $IP

SERVER="localhost"
PORT="$PORT"

echo "Cliente de EFTP"

echo "(1) send"
echo "EFTP 1.0" | nc $SERVER $PORT

echo "(2) Listen"
DATA=`nc -l -p $PORT -w 0`

echo $DATA

echo "(5) Test & send"
if [ "$DATA" != "OK_HEADER" ]
then
echo "ERROR 33: HEADER NO COINCIDE"
exit 2
fi

echo "BOOM"
sleep 1
echo "BOOM" | nc $SERVER $PORT

echo "(6) Listen"
DATA=`nc -l -p $PORT -w 0`
echo $DATA



