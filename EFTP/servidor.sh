#!/bin/bash

PORT="3333"
TIMEOUT=1

echo "Servidor de EFTP"

echo "(0) Listen"
DATA=`nc -l -p $PORT -w $TIMEOUT`

echo $DATA


#Comprovamos por separado si el header está bien
echo "(3) Test & Send"
PREFIX=`echo $DATA | cut -d " " -f 1`
VERSION=`echo $DATA | cut -d " " -f 2`

if [ "$PREFIX" != "EFTP" ]
then
	echo "ERROR 1: BAD HEADER"
	sleep 1
	echo "KO_HEADER" | nc $CLIENT $PORT
	exit 1
fi

if [ "$VERSION" != "1.0" ]
then
	echo "ERROR 1: BAD HEADER"
	sleep 1
	echo "KO_HEADER" | nc $CLIENT $PORT
	exit 1
fi

CLIENT=`echo $DATA | cut -d " " -f 3`

if [ "$CLIENT" == "" ]
then
	echo "ERROR: NO IP"
	exit 1
fi

echo "OK_HEADER"
sleep 1
echo "OK_HEADER" | nc $CLIENT $PORT


echo "(4) Listen"
DATA=`nc -l -p $PORT -w $TIMEOUT`

echo $DATA


#Comprueba si el handshake está bien
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


echo "(7a) Listen NUM_FILES"
DATA=`nc -l -p $PORT -w $TIMEOUT`

echo $DATA


#Comprueba si el prefijo es correcto y la cantidad de archivos que va a enviar
echo "(7b) Test & Send OK/KO NUM_FILES"
PREFIX=`echo $DATA | cut -d " " -f 1`
echo $PREFIX

if [ "$PREFIX" != "NUM_FILES" ]
then
	echo "ERROR 4: BAD PREFIX"
	sleep 1
	echo "KO_NUM_FILES" | nc $CLIENT $PORT
	exit 3
fi

echo "OK_NUM_FILES"
sleep 1
echo "OK_NUM_FILES" | nc $CLIENT $PORT


#Empezamos el bucle for, la cantidad de veces como cantidad de archivos tiene el cliente
echo "(7c) Loop"
NUM_FILES=`echo $DATA | cut -d " " -f 2`

echo $NUM_FILES
for NUM in `seq $NUM_FILES`
do
	echo "Archivo numero $NUM"
	
	
	echo "(8) Listen"
	DATA=`nc -l -p $PORT -w $TIMEOUT`
	echo $DATA
	
	
	#Comprueba el prefijo y el nombre del archivo. Luego se lo guarda en inbox
	echo "(12) Test & store & send"
	#COMPROBAR PREFIX
	PREFIX=`echo $DATA | cut -d " " -f 1`
	
	if [ "$PREFIX" != "FILE_NAME" ]
	then
		echo "ERROR 4: BAD PREFIX"
		sleep 1
		echo "KO_FILE_NAME" | nc $CLIENT $PORT
		exit 3
	fi
	
	echo "OK_FILE_NAME"
	sleep 1
	echo "OK_FILE_NAME" | nc $CLIENT $PORT
	
	#COMPROBAR MD5
	FILE_NAME=`echo $DATA | cut -d " " -f 2`
	MD5_CLIENT=`echo $DATA | cut -d " " -f 3`
	MD5_TEST=`echo $FILE_NAME | md5sum | cut -d " " -f 1`
	
	if [ "$MD5_CLIENT" != "$MD5_TEST" ]
	then
		echo "ERROR 5: BAD FILE_MD5"
		sleep 1
		echo "KO_FILE_MD5" | nc $CLIENT $PORT
	 	exit 4
	fi
	
	echo "OK_MD5"
	sleep 1
	echo "OK_MD5" | nc $CLIENT $PORT
	
	
	#Escuchar el contenido del archivo en cuestión y guardarlo en inbox/Archivo (Se crea en ese momento)
	echo "(13) Listen"
	#Guardar en inbox lo que nos llega. 
	#DATA=`nc -l -p $PORT -w $TIMEOUT`
	nc -l -p $PORT -w $TIMEOUT > inbox/$FILE_NAME
	
	
	#Comprobamos el interior del archivo y hacemos un reporte
	echo "(16) Store & send"
	DATA_FILE=`cat inbox/$FILE_NAME`
	
	if [ $DATA_FILE == "" ]
	then
		echo "ERROR 6: KO_DATA"
		sleep 1
		echo "KO_DATA" | nc $CLIENT $PORT
	 	exit 4
	fi
	
	echo "OK_DATA" 
	sleep 1
	echo "OK_DATA" | nc $CLIENT $PORT
	
	
	echo "(17) Listen"
	DATA=`nc -l -p $PORT -w $TIMEOUT`
	
	
	echo "(20) Test & Send"
	#COMPROBAMOS EL PREFIX
	PREFIX=`echo $DATA | cut -d " " -f 1`
	
	if [ "$PREFIX" != "FILE_MD5" ]
	then
		echo "ERROR 7: BAD_PREFIX"
		sleep 1
		echo "KO_FILE_MD5" | nc $CLIENT $PORT
	 	exit 5
	fi
	
	sleep 1
	echo "OK_PREFIX" | nc $CLIENT $PORT
	
	#COMPROBAMOS EL MD5
	FILE_MD5_CLIENT=`echo $DATA | cut -d " " -f 2`
	FILE_MD5_SERVER=`$DATA_FILE | md5sum | cut -d " " -f 1`
	
	if [ "$FILE_MD5_CLIENT" != "$FILE_MD5_SERVER" ]
	then
		echo "KO_FILE_MD5"
		sleep 1
		echo "KO_FILE_MD5" | nc $CLIENT $PORT
	 	exit 6
	fi
	
	echo "OK_DATA_FILE_MD5"
	sleep 1
	echo "OK_DATA_FILE_MD5" | nc $CLIENT $PORT

done

echo "FIN"
exit 0












