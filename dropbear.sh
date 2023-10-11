#!/bin/bash
#XPanel Alireza
repeat_count=6

for ((i = 0; i < $repeat_count; i++)); do
json_output="["

port_dropbear=$(ps aux | grep dropbear | awk NR==1 | awk '{print $17;}')
log="/var/log/auth.log"
loginsukses="Password auth succeeded"

pids=$(ps ax | grep dropbear | grep " $port_dropbear" | awk -F" " '{print $1}')

for pid in $pids
do
    pidlogs=$(grep $pid $log | grep "$loginsukses" | awk -F" " '{print $3}')
    i=0
    for pidend in $pidlogs
    do
      let i=i+1
    done
    if [ $pidend ];then
       login=$(grep $pid $log | grep "$pidend" | grep "$loginsukses")
       PID=$pid
       user=$(echo $login | awk -F" " '{print $10}' | sed -r "s/'/ /g")
       user=$(echo $user | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
       waktu=$(echo $login | awk -F" " '{print $2"-"$1,$3}')
       while [ ${#waktu} -lt 13 ]; do
           waktu=$waktu" "
       done
       while [ ${#user} -lt 16 ]; do
           user=$user" "
       done
       while [ ${#PID} -lt 8 ]; do
           PID=$PID" "
       done
       PID=$(echo $PID | sed -r -e "s/'/ /g" -e "s/ *$//" -e "s/ //g")
       user=$(echo $user | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
       json_item="{"
       json_item+="\"user\": \"$user\", "
       json_item+="\"PID\": \"$PID\", "
       json_item+="\"waktu\": \"$waktu\""
       json_item+="}"
       json_output+=" $json_item,"

    fi
done
json_output="${json_output%,}"
json_output+="]"
echo "$json_output" > /var/www/html/app/storage/dropbear.json
sleep 9
done
