#!/bin/bash
#
#
#########################################################
#
# IBM DSxx health monitoring
# 
# Usage:  v3700_status.sh <DS_controller> OPTIONS
# Requirements: SSH Key-Based Authentication in place
# Params:
#         $1 V3700 ip / hostname
#         $2 parameter to measure (lsarray, lsdrive)
#              IF $2=lsarray $3 is number of drive
#              IF $2=lsdrive $3 is number of drive
#
# Output:
#
#
# Original author Francisco Tudel 2015
#
#########################################################
#
#   Check state of IBM v3700 Health Status
#
#   uses sshpass and ssh to obtain data
#
#
#
#
#########################################################


NOW=$(date +"%F")
NOWT=$(date +"%H_%M_%S")
LOGFILE="log_cabina_$NOW__$NOWT.log"
# Enable debug at end

#ssh -o StrictHostKeyChecking=no administrador@$1 ' lsdrive ' > /var/log/discos_cabina.txt
# sshpass -p nagios ssh -o StrictHostKeyChecking=no nagios@$1 ' lsdrive ' > /var/log/discos_cabina.txt
# awk '$1=='"$BUSCA"' {print $2}' /var/log/discos_cabina.txt

#
# echo "$RESULT"
#echo "$RESULT" | awk '$1=='"$BUSCA"' {print $2}'

if [ $# -lt 2 ]
 then
    echo "SCRIPT_ERROR: Not enough parameters"
    echo " Usage: v3700_status.sh <SVC_IP> <Parameter to list> <Data for the parameter>"
    echo "Parameters: lsdrive,lsarray,lsvdisk,lsenclosure,lsenclosurebattery,lsenclosurecanister,lsenclosurepsu,lsenclosureslot,logstatus,logerror"
  exit 2
fi


#
# Check the health status via cli
#

if [[ $2 == 'discoverdrives' ]]; then
  RESULT=$(ssh -o StrictHostKeyChecking=no $1 '( lsdrive -nohdr -delim :)' )
  count=0
  echo "["
  for line in ${RESULT//\\n/ }
  do
    while IFS=':' read -ra fields; do
      if [[ $count>0 ]]; then
        echo ","
      fi
      printf "{\"{#ENCLOSURE_ID}\":\"${fields[9]}\", \"{#DRIVE_ID}\":\"${fields[10]}\"}"
      count=$((count+1))
    done <<< "$line"
  done
  echo "]"
fi

if [[ $2 == 'discoverenclosures' ]]; then
  RESULT=$(ssh -o StrictHostKeyChecking=no $1 '( lsenclosure -nohdr -delim :)' )
  count=0
  echo "["
  for line in ${RESULT//\\n/ }
  do
    while IFS=':' read -ra fields; do
      if [[ $count>0 ]]; then
        echo ","
      fi
      printf "{\"{#ENCLOSURE_ID}\":\"${fields[0]}\"}"
      count=$((count+1))
    done <<< "$line"
  done
  echo "]"
fi

if [[ $2 == 'discoverarrays' ]]; then
  RESULT=$(ssh -o StrictHostKeyChecking=no $1 '( lsarray -nohdr -delim :)' )
  count=0
  echo "["
  for line in ${RESULT//\\n/ }
  do
    while IFS=':' read -ra fields; do
      if [[ $count>0 ]]; then
        echo ","
      fi
      printf "{\"{#ARRAY_ID}\":\"${fields[0]}\"}"
      count=$((count+1))
    done <<< "$line"
  done
  echo "]"
fi

if [[ $2 == 'discovervdisks' ]]; then
  RESULT=$(ssh -o StrictHostKeyChecking=no $1 '( lsvdisk -nohdr -delim :)' )
  count=0
  echo "["
  for line in ${RESULT//\\n/ }
  do
    while IFS=':' read -ra fields; do
      if [[ $count>0 ]]; then
        echo ","
      fi
      printf "{\"{#VDISK_ID}\":\"${fields[0]}\", \"{#VDISK_NAME}\":\"${fields[1]}\"}"
      count=$((count+1))
    done <<< "$line"
  done
  echo "]"
fi


#lsdrive -> state of drives
if [[ $2 == 'lsdrive' ]]; then
  BUSCA=$3
  RESULT=$(ssh -o StrictHostKeyChecking=no $1 "( lsdrive -filtervalue enclosure_id=$3:slot_id=$4 -delim : -nohdr )" )
  while IFS=':' read -ra fields; do
    echo "${fields[1]}"
  done <<< "$RESULT"
  #echo "$RESULT" | awk '$1=='"$BUSCA"' {print $2}'
fi

#lsarray -> state of array MDisks
if [[ $2 == 'lsarray' ]]; then
  BUSCA=$3
  RESULT=$(ssh -o StrictHostKeyChecking=no $1 '( lsarray )' )
  # echo "$RESULT" | awk '$1=='"$BUSCA"' {print $3}'
  if [ -z "$4" ]
  then
    echo "$RESULT" | awk '$1=='"$BUSCA"' {print $3}'
  else
    #echo "$RESULT" | awk '$1=='"$BUSCA"' {print $1 " " $2 " " $3 " " $2 " " $3}'
    #get name of array
	if [[ $4 == 'name' ]]; then
            echo "$RESULT" | awk '$1=='"$BUSCA"' {print $3}'
       fi
  fi

fi

#lsvdisk -> state of volumes (lun's/vdisk's)
if [[ $2 == 'lsvdisk' ]]; then
  BUSCA=$3
  RESULT=$(ssh -o StrictHostKeyChecking=no $1 '( lsvdisk )' )
  #echo "$RESULT" | awk '$1=='"$BUSCA"' {print $3}'
  if [ -z "$4" ]
  then
    echo "$RESULT" | awk '$1=='"$BUSCA"' {print $3}'
  else
    #echo "$RESULT" | awk '$1=='"$BUSCA"' {print $1 " " $2 " " $3 " " $2 " " $3}'
    #get name of array
	if [[ $4 == 'name' ]]; then
            echo "$RESULT" | awk '$1=='"$BUSCA"' {print $2}'
       fi
  fi
fi

# lsenclosure -> state of enclosures
if [[ $2 == 'lsenclosure' ]]; then
  BUSCA=$3
  RESULT=$(ssh -o StrictHostKeyChecking=no $1 '( lsenclosure )' )
  echo "$RESULT" | awk '$1=='"$BUSCA"' {print $2}'
fi

# lsenclosurebattery -> state of batteries
if [[ $2 == 'lsenclosurebattery' ]]; then
  BUSCA=$3
  BUSCA2=$4
  RESULT=$(ssh -o StrictHostKeyChecking=no $1 '( lsenclosurebattery )' )
  #echo "$RESULT" | awk '$1=='"$BUSCA"' {print $3}'
  echo "$RESULT" | awk '$1=='"$BUSCA"' && $2=='"$BUSCA2"'  {print $3}'
fi

# lsenclosurecanister -> state of canister/nodes
if [[ $2 == 'lsenclosurecanister' ]]; then
  BUSCA=$3
  BUSCA2=$4
  RESULT=$(ssh -o StrictHostKeyChecking=no $1 '( lsenclosurecanister )' )
  #echo "$RESULT" | awk '$1=='"$BUSCA"' && $2=='"$BUSCA2"'  {print $3 ";" $4}'
  echo "$RESULT" | awk '$1=='"$BUSCA"' && $2=='"$BUSCA2"'  {print $3}'

fi

# lsenclosurepsu -> state of psu's
if [[ $2 == 'lsenclosurepsu' ]]; then
  BUSCA=$3
  BUSCA2=$4
  RESULT=$(ssh -o StrictHostKeyChecking=no $1 '( lsenclosurepsu )' )
  echo "$RESULT" | awk '$1=='"$BUSCA"' && $2=='"$BUSCA2"'  {print $3}'
fi

# lsenclosureslot -> state of port enclosure slots
# Muestra yes o no dependiendo de si el disco esta presente o no, si hay mas de un enclosure no se como va
if [[ $2 == 'lsenclosureslot' ]]; then
  BUSCA=$3
  RESULT=$(ssh -o StrictHostKeyChecking=no $1 '( lsenclosureslot )' )
  echo "$RESULT" | awk '$2=='"$BUSCA"' {print $3}'
fi

if [[ $2 == 'lsenclosureslotextended' ]]; then
  RESULT=$(ssh -o StrictHostKeyChecking=no $1 "( lsenclosureslot -slot $3 $4 )" )
  echo "$RESULT" | grep "drive_present" | cut -f2- -d" "
  #echo "$RESULT"
fi



# logerror -> event log most important
if [[ $2 == 'logerror' ]]; then
  BUSCA=$3
  RESULT=$(ssh -o StrictHostKeyChecking=no $1 '( lseventlog -expired no -fixed no -monitoring no -message no -order severity )' )
  echo "$RESULT"
fi

# logerrorall -> event log all
if [[ $2 == 'logerrorall' ]]; then
  BUSCA=$3
  RESULT=$(ssh -o StrictHostKeyChecking=no $1 '( lseventlog )' )
  echo "$RESULT"
fi

# logstatus -> state of all paramaters
if [[ $2 == 'logstatus' ]]; then

	NOW=$(date +"%d_%m_%y_")
	NOWT=$(date +"%H_%M_%S")
	RESULT=" "
	RESULT+=lsdrive___$NOW__$NOWT
	RESULT+=$(echo \\n--\\n)
	RESULT+=$(echo --)
	RESULT+=$(sshpass -p $3 ssh -o StrictHostKeyChecking=no $2@$1 '( lsdrive)' )
	RESULT+=lsarray___$NOW__$NOWT
	RESULT+=$(echo --)
	RESULT+=$(echo --)
	RESULT+=$(sshpass -p $3 ssh -o StrictHostKeyChecking=no $2@$1 '( lsarray)' )
	RESULT+=lsvdisk___$NOW__$NOWT
	RESULT+=$(echo --)
	RESULT+=$(echo --)
	RESULT+=$(sshpass -p $3 ssh -o StrictHostKeyChecking=no $2@$1 '( lsvdisk)' )
	RESULT+=lsenclosure___$NOW__$NOWT
	RESULT+=$(echo --)
	RESULT+=$(echo --)
	RESULT+=$(sshpass -p $3 ssh -o StrictHostKeyChecking=no $2@$1 '( lsenclosure)' )
	RESULT+=lsenclosurebattery___$NOW__$NOWT
	RESULT+=$(echo --)
	RESULT+=$(echo --)
	RESULT+=$(sshpass -p $3 ssh -o StrictHostKeyChecking=no $2@$1 '( lsenclosurebattery)' )
	RESULT+=lsenclosurepsu___$NOW__$NOWT
	RESULT+=$(echo --)
	RESULT+=$(echo --)
	RESULT+=$(sshpass -p $3 ssh -o StrictHostKeyChecking=no $2@$1 '( lsenclosurepsu)' )
	RESULT+=lsenclosureslot___$NOW__$NOWT
	RESULT+=$(echo --)
	RESULT+=$(echo --)
	RESULT+=$(sshpass -p $3 ssh -o StrictHostKeyChecking=no $2@$1 '( lsenclosureslot)' )
	RESULT+=lsenclosureslotx___$NOW__$NOWT
	RESULT+=$(echo --)
	RESULT+=$(echo --)
	echo "$RESULT"
fi

### DEBUG ###
# echo "$RESULT"