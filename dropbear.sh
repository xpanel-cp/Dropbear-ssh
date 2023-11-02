#!/bin/bash
#XPanel Alireza

json_file="/var/www/html/app/storage/dropbear.json"
idrop=0

if [ ! -e "$json_file" ]; then
    touch "$json_file"
    chmod 644 "$json_file"
fi

while [ $idrop -lt 10 ]; do
    port_dropbear=$(ps aux | grep dropbear | awk NR==1 | awk '{print $17;}')
    log="/var/log/auth.log"
    loginsukses="Password auth succeeded"

    pids=$(ps ax | grep dropbear | grep " $port_dropbear" | awk -F" " '{print $1}')

    for pid in $pids; do
        pidlogs=$(grep $pid $log | grep "$loginsukses" | awk -F" " '{print $3}')
        i=0
        for pidend in $pidlogs; do
            let i=i+1
        done
        if [ -n "$pidend" ]; then
            login=$(grep $pid $log | grep "$pidend" | grep "$loginsukses")
            PID=$pid
            user=$(echo $login | awk -F" " '{print $10}' | sed -r "s/'/ /g")
            user=$(echo $user | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
            waktu=$(echo $login | awk -F" " '{print $2"-"$1,$3}')
            while [ ${#waktu} -lt 13 ]; do
                waktu=$waktu" "
            done

            if [ -n "$user" ] && ! jq -e '.[] | select(.user == $user and .PID == $PID) | length == 0' --arg user "$user" --arg PID "$PID" < "$json_file" > /dev/null; then
                json_item="{"
                json_item+="\"user\": \"$user\", "
                json_item+="\"PID\": \"$PID\", "
                json_item+="\"waktu\": \"$waktu\""
                json_item+="}"

                jq ". += [$json_item]" < "$json_file" > "${json_file}.tmp" && mv "${json_file}.tmp" "$json_file"
            fi
        fi
    done

    wait
    rm -fr /var/log/auth.log
    systemctl restart syslog
    sleep 5
    idrop=$((idrop + 1))
done
