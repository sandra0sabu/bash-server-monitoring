#!/bin/bash


THRESHOLD=4
EMAIL="your-email@example.com"
ALERTS=""
HOST=$(hostname)

#calculate disk space

disk_space(){
for DISK in $(df -P | awk 'NR>1 {print $6}')
do
  USAGE=$(df -P "$DISK" | awk 'NR==2 {gsub("%","",$5); print $5}')
if [ "$USAGE" -gt "$THRESHOLD" ]; then
   echo "WARNING: $DISK Usage is ${USAGE}%"
   ALERTS="${ALERTS} WARNING: Disk $DISK Usage is ${USAGE}% \n"
else 
   echo "OK: Disk Usage is ${DISK}%"
fi
done
}

send_alert(){
if [ -n "$ALERTS" ]; then
	printf "Server: %s\n\n%b" "$HOST" "$ALERTS" \
		| mail -s "System Resource Alert - $HOST" "$EMAIL"
	echo "consolidated alert email sent"
else
        echo "No alert. Email is not required"
fi	
}

#checking memory

check_memory(){
MEMORY=$(free | awk '/Mem:/ {printf "%.0f", ($3/$2)*100}')

if [ "$MEMORY" -gt "$THRESHOLD" ]; then
   echo "WARNING: Memory Usage is ${MEMORY}%"
   echo "Memory Usage is ${MEMORY}% on $HOST" \
	   | mail -s "WARNING: High Memory Usage" "$EMAIL"
else
   echo "OK: Memory Usage is ${MEMORY}%"
fi
}

main(){
     disk_space
     send_alert
     check_memory
}

main

