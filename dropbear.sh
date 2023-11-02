  GNU nano 4.8                                                                  /var/www/html/dropbear.sh                                                                            
#!/bin/bash
#XPanel Alireza

if ! grep -q "{\"user\": \"\", \"PID\": \"\", \"waktu\": \"\"}" "/var/www/html/app/storage/dropbear.json"; then
    # اگر متن وجود نداشته باشد، فایل را ایجاد کنید
    touch "/var/www/html/app/storage/dropbear.json"
fi

idrop=0

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
        if [ $pidend ]; then
            login=$(grep $pid $log | grep "$pidend" | grep "$loginsukses")
            PID=$pid
            user=$(echo $login | awk -F" " '{print $10}' | sed -r "s/'/ /g")
            user=$(echo $user | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
            waktu=$(echo $login | awk -F" " '{print $2"-"$1,$3}')
            while [ ${#waktu} -lt 13 ]; do
                waktu=$waktu" "
            done

            # استفاده از jq برای چک کردن وجود تکراری نبودن user و PID و همچنین خالی نبودن user
            if [ -n "$user" ] && ! jq -e '.[] | select(.user == $user and .PID == $PID) | length == 0' --arg user "$user" --arg PID "$PID" < "/var/www/html/app/storage/dropbear.jso>                user=$(echo $user | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
                json_item="{"
                json_item+="\"user\": \"$user\", "
                json_item+="\"PID\": \"$PID\", "
                json_item+="\"waktu\": \"$waktu\""
                json_item+="}"

                # اضافه کردن به فایل JSON با استفاده از jq
                jq ". += [$json_item]" < "/var/www/html/app/storage/dropbear.json" > "/var/www/html/app/storage/dropbear.json.tmp" && mv "/var/www/html/app/storage/dropbear.json.tm>            fi
        fi
    done

    wait
    rm -fr /var/log/auth.log
    systemctl restart syslog
    sleep 5
    idrop=$((idrop + 1))
done
