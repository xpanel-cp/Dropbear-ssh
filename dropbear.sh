#!/bin/bash
#XPanel Alireza

json_output="["

log="/var/log/auth.log"
loginsukses="Password auth succeeded"

time_5_hours_ago=$(date -d "5 hours ago" "+%b %d %T")

while IFS= read -r line; do
    if [[ "$line" == *"$loginsukses"* && "$line" > *"$time_5_hours_ago"* ]]; then
        pid=$(echo "$line" | awk '{print $5}' | sed "s/'//g")
        pid=$(echo "$pid" | grep -oP '\[\K\d+(?=\]:)')
        waktu=$(echo "$line" | awk '{print $1 "-" $2}')
        user=$(echo "$line" | awk '{print $10}' | sed "s/'//g")
        user=$(echo -e "$user" | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

        json_item="{"
        json_item+="\"user\": \"$user\", "
        json_item+="\"PID\": \"$pid\", "
        json_item+="\"waktu\": \"$waktu\""
        json_item+="}"
        json_output+=" $json_item,"
    fi
done < "$log"

json_output="${json_output%,}"
json_output+="]"
echo "$json_output" > /var/www/html/app/storage/dropbear.json
