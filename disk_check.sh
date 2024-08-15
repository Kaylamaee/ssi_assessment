#!/bin/bash

while getopts ":c:w:e:" opt; do
	case $opt in
	  c) critical_threshold="$OPTARG" ;;
	  w) warning_threshold="$OPTARG" ;;
	  e) email_address="OPTARG" ;;
	 \?) echo "Invalid option: -$OPTARG"; exit 1;;

	esac
done

if [ -z "$critical_threshold" ] || [ -z "$warning_threshold" ] || [ -z "$email_address" ]; then
	echo "Required parameters: -c <critical_threshold>, -w <warning_threeshold>, -e <email_address>"
	exit 1
fi

if [ $critical_threshold -le $warning_threshold ]; then
	echo "Critical threshold must be greater than warning threshold"
	exit 1
fi

DISK_PARTITION=$(df -P | awk '0+$5 >= '$warning_threshold' {print}')

if [ -n "$DISK_PARTITION" ]; then
 	if [ $DISK_PARTITION -ge $critical_threshold ]; then
	   echo "Disk usage is greater than or equal to critical threshold ($critical_threshold%)"
	   exit 2
	else
	   echo "Disk usage is greater than or equal to warning threshold ($warning_threshold%) but less than critical threshold ($critical_threshold%)"
	   exit 1
	fi
	else
	  echo "Disk usage is less than warning threshold ($warning_threshold%)"
          exit 0
	fi 

