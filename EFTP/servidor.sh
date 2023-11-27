#!/bin/bash

CLIENT="localhost"
PORT="$PORT"

echo "Servidor de EFTP"

echo "(0) Listen"
DATA=`nc -l -p  -w 0`

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
DATA=`nc -l -p $PORT -w 0`

echo $DATA

echo "(7) Test & send"
if [ "$DATA" != "BOOM" ]
then
	echo "ERROR 3: BAD HANDSHAKE"
	sleep 1
	echo "KO_HANDSHAKE" | nc $CLIENT $PORT
	exit 2
fi

echo "(8) Listen"
DATA=`nc -l -p $PORT -w 0`
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
DATA=`nc -l -p $PORT -w 0`

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












