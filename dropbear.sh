#!/bin/bash
#XPanel Alireza

json_file="/var/www/html/app/storage/dropbear.json"
idrop=0

if [ ! -e "$json_file" ] || [ ! -s "$json_file" ]; then
    echo "[]" > "$json_file"
    chmod 777 "$json_file"
fi
port_dropbear=$(ps aux | grep dropbear | awk NR==1 | awk '{print $13;}')
log="/var/log/auth.log"
loginsukses="Password auth succeeded"
while [ $idrop -lt 10 ]; do
    pids=$(lsof -i :"$port_dropbear" -n | grep ESTABLISHED | awk -F" " '{print $2}')
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

            if [ -n "$user" ]; then
              if jq ".[] | select(.user == \"$user\" and .PID == \"$PID\")" "$json_file" | grep -q "$user"; then
                continue
              else
                json_item="{\"user\": \"$user\", \"PID\": \"$PID\", \"waktu\": \"$waktu\"}"
                jq ". += [$json_item]" "$json_file" > "${json_file}.tmp" && mv "${json_file}.tmp" "$json_file"
              fi
            fi
        fi
    done
    wait
if [ -e "$json_file" ]; then
  jsonData_remove=$(jq -c '.[]' "$json_file")
  unique_entries=()
  while IFS= read -r entry_remove; do
    user_remove=$(jq -r '.user' <<< "$entry_remove")
    PID_remove=$(jq -r '.PID' <<< "$entry_remove")

    if [ -n "$user_remove" ] && [ -n "$PID_remove" ]; then
      if ps -p "$PID_remove" > /dev/null; then
        echo "User: $user_remove, PID: $PID_remove is running."
      else
        echo "User: $user_remove, PID: $PID_remove is not running. Removing the entry."
        jq "del(.[] | select(.user == \"$user_remove\" and .PID == \"$PID_remove\"))" "$json_file" > "${json_file}.tmp" && mv "${json_file}.tmp" "$json_file"
      fi
    fi
  done <<< "$jsonData_remove"
fi
python3 /var/www/html/app/storage/removedupdrop.py
    sleep 5
    idrop=$((idrop + 1))
done
dropbear_status=$(service dropbear status)
if [[ $dropbear_status == *"is not running"* ]]; then
    service dropbear start
echo "Start dropbear"
fi
#rm -fr /var/log/auth.log
#systemctl restart syslog
