#!/bin/bash

critical_threshold=""
warning_threshold=""
email_address=""

usage(){
	echo "Usage: $0 -c critical_threshold -w warning_threshold -e email_adress"
	exit 1
}

if [ "$#" -ne 6 ]; then
  usage
fi

while getopts ":c:w:e:" opt; do
	case $opt in
		c) critical_threshold=$OPTARG ;;
		w) warning_threshold=$OPTARG ;;
		e) email_address=$OPTARG ;;
		\?) echo "Invalid option: -$OPTARG" >&2  exit 1 ;;
		:) echo "Option -$OPTARG requires an argument." >&2 exit 1 ;;
	esac
done

if ! [[ "$critical_threshold" =~ ^[0-9]+$ ]] || ! [[ "$warning_threshold" =~ ^[0-9]+$ ]]; then
	echo "critical and warning thresholds must be numeric"
	usage
fi 

if [ "$critical_threshold" -le "$warning_threshold" ]; then
	echo "Critical threshold must be greater than the warning threshold." 
	exit 1
fi

total_memory=$(free | grep Mem: | awk '{print $2}')
memory_usage=$(free | grep Mem: | awk '{print $3}' )

used_percentage=$(( (USED_MEMORY * 100) / total_memory ))

 if ["$used_percentage" -ge "$critical_threshold" ]; then
	echo "Critical: Memory usage is at ${used_percentage}%"
	if [ -n "$email_address" ]; then
		echo "Sending report to $email_address..."
		echo "Critical: Memory usage is at ${used_percentage}%" | mail -s "Memory Check Report" "$email_address"
	fi
	exit 2
 elif ["$used_percentage" -ge "$warning_threshold" ]; then
	echo "Warning: Memory usage is at ${used_memory}%"
	if [ -n "$email_address" ]; then
	   echo "Sending report to $email_address..."
	  echo "Warning: Memory usage is at ${used_percentage}%" | mail -s "Memory Check REport" "$email_address"
	fi
	exit 1
    else
	echo "Normal: Memory usage is at ${used_percentage}%"
  	exit 0
fi
