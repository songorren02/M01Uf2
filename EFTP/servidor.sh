#!/bin/bash

CLIENT="localhost"
PORT="3333"
TIMEOUT="1"

echo "Servidor de EFTP"

echo "(0) Listen"
DATA=`nc -l -p $PORT -w $TIMEOUT`

echo $DATA

echo "(3) Test & Send"
if [ "$DATA" != "EFTP 1.0" ]
then
	echo "ERROR 1: BAD HEADER"
	sleep 1
	echo "KO_HEADER" | nc $CLIENT $PORT
	exit 1
fi

echo "OK_HEADER"
sleep 1
echo "OK_HEADER" | nc $CLIENT $PORT

echo "(4) Listen"
DATA=`nc -l -p $PORT -w $TIMEOUT`

echo $DATA

echo "(7) Test & send"
if [ "$DATA" != "BOOOM" ]
then
	echo "ERROR 3: BAD HANDSHAKE"
	sleep 1
	echo "KO_HANDSHAKE" | nc $CLIENT $PORT
	exit 2
fi

sleep 1
echo "OK_HANDSHAKE" | nc $CLIENT $PORT

echo "(8) Listen"
DATA=`nc -l -p $PORT -w $TIMEOUT`
echo $DATA

echo "(12) Test & store & send"

PREFIX=`echo $DATA | cut -d " " -f 1`

if [ "$PREFIX" != "FILE_NAME" ]
then
	echo "ERROR 4: WRONG FILE_NAME"
	sleep 1
	echo "KO_FILE_NAME" | nc $CLIENT $PORT
	exit 3
fi

FILE_NAME=`echo $DATA | cut -d " " -f 2`
echo "OK_FILE_NAME"
sleep 1
echo "OK_FILE_NAME" | nc $CLIENT $PORT

echo "(13) Listen"
DATA=`nc -l -p $PORT -w $TIMEOUT`

echo "(16) Store & send"
if [ "$DATA" == "" ]
then
	echo "ERROR 4: BAD FILE NAME PREFIX"
	sleep 1
	echo "KO_DATA" | nc $CLIENT $PORT
	exit 4
fi

echo $DATA > inbox/$FILE_NAME

sleep 1
echo "OK_DATA" | nc $CLIENT $PORT

echo "FIN"
exit 0












