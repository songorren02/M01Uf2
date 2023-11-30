#!/bin/bash

echo $#
echo $0

if [ $# == 0 ]
then
	SERVER="localhost"
else
	SERVER="$1"
fi

SERVER="localhost"

IP=`ip address | grep inet | grep enp0s3 | cut -c 10-19`

echo $IP

PORT="3333"
TIMEOUT="1"

echo "Cliente de EFTP"

echo "(1) send"
echo "EFTP 1.0 $IP" | nc $SERVER $PORT


echo "(2) Listen"
DATA=`nc -l -p $PORT -w $TIMEOUT`

echo $DATA


echo "(5) Test & send"
if [ "$DATA" != "OK_HEADER" ]
then
echo "ERROR 2: HEADER NO COINCIDE"
exit 2
fi

echo "BOOOM"
sleep 1
echo "BOOOM" | nc $SERVER $PORT


echo "(6) Listen"
DATA=`nc -l -p $PORT -w $TIMEOUT`

echo $DATA


echo "(9) Test"
if [ "$DATA" == "KO_HANDSHAKE" ]
then
	echo "ERROR 3: BAD HANDSHAKE"
	exit 2
fi


#Enviar el archivo
echo "(10) Send"
MD5=`echo $FILE | md5sum | cut -d " " -f 1`
FILE="fary1.txt"

sleep 1
echo "FILE_NAME $FILE $MD5"  | nc $SERVER $PORT


echo "(11) Listen"
DATA=`nc -l -p $PORT -w $TIMEOUT`


echo "(14) Test & Send"
if [ "$DATA" == "KO_FILE_NAME" ]
then
	echo "ERROR 4: WRONG FILE NAME"
	exit 3
fi

sleep 1
cat imgs/fary1.txt | nc $SERVER $PORT


echo "(15) Listen"
DATA=`nc -l -p $PORT -w $TIMEOUT`

if [ "$DATA" != "OK_DATA" ]
then
	echo "ERROR 5: BAD DATA"
	exit 4
fi

echo "(18) Send"
FILE_MD5=`cat $FILE | md5sum | cut -d " " -f 1`

echo "FILE_MD5"
sleep 1
echo "FILE_MD5 $FILE_MD5" | nc $SERVER $PORT


echo "(19) Listen"
DATA=`nc -l -p $PORT -w $TIMEOUT`


echo "(21) Test"
if [ "$DATA" != "OK_FILE_MD5" ]
then
	echo "ERROR 6: BAD FILE MD5"
	exit 6
fi

echo "FIN"
exit 0











