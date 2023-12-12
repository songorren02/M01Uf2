#!/bin/bash

echo $#
echo $0

if [ $# == 0 ]
then
	SERVER="localhost"
elif [ $# -ge 1 ]
then
	SERVER="$1"
fi

IP=`ip address | grep inet | grep enp0s3 | cut -c 10-19`

echo $IP

PORT="3333"
TIMEOUT=1

echo "Cliente de EFTP"

#PREGUNTA RAFA
if [ $# -eq 2 ]
then
	echo "(-1) Reset"
	echo "RESET" | nc $SERVER $PORT

	sleep 2
fi


#Enviar el header y la ip
echo "(1) send"
echo "EFTP 1.0 $IP" | nc $SERVER $PORT


echo "(2) Listen"
DATA=`nc -l -p $PORT -w $TIMEOUT`

echo $DATA

#Testeamos el header
echo "(5) Test & send"
if [ "$DATA" != "OK_HEADER" ]
then
	echo "ERROR 2: HEADER NO COINCIDE"
	exit 2
fi
echo "OK_HEADER"

#Enviamos el handshake
echo "BOOOM"
sleep 1
echo "BOOOM" | nc $SERVER $PORT


echo "(6) Listen"
DATA=`nc -l -p $PORT -w $TIMEOUT`

echo $DATA


#Comprovamos el handshake (doble comprovación)
echo "(9) Test"
if [ "$DATA" != "OK_HANDSHAKE" ]
then
	echo "ERROR 3: BAD HANDSHAKE"
 	sleep 1
	echo "KO_HANDSHAKE" | nc $SERVER $PORT 
	exit 2
fi


#Enviamos la cantidad de archivos que hay dentro de imgs
echo "(9a) SEND NUM_FILES"
NUM_FILES=`ls imgs/ | wc -l`

echo "NUM_FILES"
sleep 1
echo "NUM_FILES $NUM_FILES" | nc $SERVER $PORT


#Comprovamos si hemos enviado bien el prefijo y la catidad de archivos
echo "(9b) Listen KO/OK NUM_FILES"
DATA=`nc -l -p $PORT -w $TIMEOUT`

if [ "$DATA" != "OK_NUM_FILES" ]
then
	echo "ERROR 3.1: BAD PREFIX"
	exit 2
fi


#Empezamos el loop de envío de archivos
echo "(9c) Loop"
for FILE_NAME in `ls imgs/`
do
	
	
	#Enviar el archivo
	echo "(10) Send"
	MD5=`echo $FILE_NAME | md5sum | cut -d " " -f 1`
	#FILE_NAME="fary1.txt"
	
	sleep 1
	echo "FILE_NAME $FILE_NAME $MD5"  | nc $SERVER $PORT
	
	
	echo "(11) Listen"
	DATA=`nc -l -p $PORT -w $TIMEOUT`
	
	
	#Comrpueba si ha ido bien el envío y envía el contenido del archivo
	echo "(14) Test & Send"
	if [ "$DATA" != "OK_FILE_NAME" ]
	then
		echo "ERROR 4: WRONG FILE_NAME"
		exit 3
	fi
	
	sleep 1
	cat imgs/$FILE_NAME | nc $SERVER $PORT
	
	
	#Comprueba si ha ido bien el envío del contenido del archivo (DATA)
	echo "(15) Listen & Test"
	DATA=`nc -l -p $PORT -w $TIMEOUT`
	
	if [ "$DATA" != "OK_DATA" ]
	then
		echo "ERROR 5: BAD DATA"
		exit 4
	fi
	
	
	#Envia el MD5 del contenido del archivo
	echo "(18) Send"
	DATA_FILE_MD5=`cat imgs/$FILE_NAME | md5sum | cut -d " " -f 1`
	
	echo "FILE_MD5"
	sleep 1
	echo "FILE_MD5 $DATA_FILE_MD5" | nc $SERVER $PORT
	
	
	echo "(19) Listen"
	DATA=`nc -l -p $PORT -w $TIMEOUT`
	
	
	#Comprueba que el envío del md5 del contenido del archivo haya ido bien
	echo "(21) Test"
	if [ "$DATA" != "OK_DATA_FILE_MD5" ]
	then
		echo "ERROR 6: BAD DATA_FILE_MD5"
		exit 6
	fi

done

echo "FIN"
exit 0











