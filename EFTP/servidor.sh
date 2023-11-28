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
	echo "ERROR 4: BAD PREFIX"
	sleep 1
	echo "KO_FILE_NAME" | nc $CLIENT $PORT
	exit 3
fi

FILE_NAME=`echo $DATA | cut -d " " -f 2`

echo "OK_FILE_NAME"
sleep 1
echo "OK_FILE_NAME" | nc $CLIENT $PORT

#COMPROBAR MD5
MD5_CLIENT=`echo $DATA | cut -d " " -f 3`
MD5_TEST=`echo $FILE_NAME | md5sum | cut -d " " -f 1`

if [ "$MD5" != "$MD5_TEST" ]
then
	echo "ERROR 5: BAD MD5"
	sleep 1
	echo "KO_MD5" | nc $CLIENT $PORT
fi

echo "OK_MD5"
sleep 1
echo "OK_MD5" | nc $CLIENT $PORT


echo "(13) Listen"
DATA=`nc -l -p $PORT -w $TIMEOUT`

echo "(16) Store & send"
DATA_FILE=`cat $FILE_NAME`

if [ $DATA_FILE == "" ]
then
	echo "KO_DATA"
	sleep 1
	echo "KO_DATA" | nc $CLIENT $PORT
fi

echo $DATA > inbox/$FILE_NAME

sleep 1
echo "OK_DATA" | nc $CLIENT $PORT


echo "(17) Listen"
DATA=`nc -l -p $PORT -w $TIMEOUT`


echo "(20) Test & Send"
#COMPROBAMOS EL PREFIX
PREFIX=`echo $DATA | cut -d " " -f 1`

if [ "$PREFIX" != "FILE_MD5" ]
then
	echo "BAD_PREFIX"
	sleep 1
	echo "KO_PREFIX" | nc $CLIENT $PORT
fi

sleep 1
echo "OK_PREFIX" | nc $CLIENT $PORT

#COMPROBAMOS EL MD5
FILE_MD5_CLIENT=`echo $DATA | cut -d " " -f 2`
FILE_MD5_SERVER=`cat $DATA_FILE | md5sum | cut -d " " -f 1`

if [ $FILE_MD5_CLIENT != $FILE_MD5_SERVER ]
then
	echo "KO_FILE_MD5"
	sleep 1
	echo "KO_FILE_MD5" | nc $CLIENT $PORT
fi

echo "FIN"
exit 0












