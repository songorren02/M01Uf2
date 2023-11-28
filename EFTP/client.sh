#!/bin/bash

IP=`ip address | grep inet | grep enp0s3 | cut -c 10-19`

echo $IP

SERVER="localhost"
PORT="3333"

echo "Cliente de EFTP"

echo "(1) send"
echo "EFTP 1.0" | nc $SERVER $PORT


echo "(2) Listen"
DATA=`nc -l -p $PORT -w 0`

echo $DATA


echo "(5) Test & send"
if [ "$DATA" != "OK_HEADER" ]
then
echo "ERROR 2: HEADER NO COINCIDE"
exit 2
fi

echo "BOOM"
sleep 1
echo "BOOM" | nc $SERVER $PORT


echo "(6) Listen"
DATA=`nc -l -p $PORT -w 0`

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
DATA=`nc -l -p $PORT -w 0`


echo "(14) Test & Send"
if [ "$DATA" == "KO_FILE_NAME" ]
then
	echo "ERROR 4: WRONG FILE NAME"
	exit 3
fi

sleep 1
cat imgs/fary1.txt | nc $SERVER $PORT


echo "(15) Listen"
DATA=`nc -l -p $PORT -w 0`

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
DATA=`nc -l -p $PORT -w 0`

echo "FIN"
exit 0











