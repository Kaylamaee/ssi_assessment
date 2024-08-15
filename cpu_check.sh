#!/bin/bash

while getopts ":c:w:e:" opt; do
 case $opt in
	c) critical_threshold="$OPTARG" ;;
	w) warning_threshold="$OPTARG" ;;
	e) email_address="$OPTARG" ;;
	\?) echo "Invalid option: -$OPTARG"; exit 1 ;;

    esac
done

if [ -z "$critical_threshold" ] || [ -z "$warning_threshold" ] || [ -z "$email_address" ]; then
	echo "Required parameters: -c <critical_threshold>, -w <warning_threshold>, -e <email_address>"
	exit 1
fi

if [ $critical_threshold -le $warning_threshold ]; then
	echo "Critical threshold must be greater than warning threshold"
	exit 1
fi

TOTAL_CPU=$(top -bn1 | grep "Cpu(s)" | \sed "s/.*,*\([0-9.]*\)%*id.*/\1/" | awk '{print 100 - $1"%"}')

if [ -z "$TOTAL_CPU" ]; then
	echo "Error: unable to get CPU Usage"
	exit 1
fi

TOTAL_CPU_VALUE=$(echo "${TOTAL_CPU}" | sed 's/%//')

if (( TOTAL_CPU_VALUE >= critical_threshold )); then
	Subject="CPU Usage Critical: ${TOTAL_CPU}"
	Message="CPU usage has reached a critical level of $TOTAL_CPU}. PLease take immediate action to reduce the load."
	exit_code=2

elif (( TOTAL_CPU >= warning_threshold )); then
	Subject="CPU Usage Warning: ${TOTAL_CPU}"
	Message="CPU Usage has reached a warning level of ${TOTAL_CPU}. Please take acion to reduce the load to prevent critical levels."
	exit_code=1
else
	Subject="CPU Usage Normal: ${TOTAL_CPU}%"
	Message="CPU usage is normal at ${TOTAL_CPU}"
	exit_code=0
fi

echo "Sending email report to $email_address"
echo "Subject: $Subject"
echo "Message: $Message"

echo "$Message" | mail -s "$Subject" "email_address"

exit $exit_code
