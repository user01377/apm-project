#!/bin/bash

APMS=("APM1" "APM2" "APM3" "APM4" "APM5" "APM6")

cleanup() {
    echo "Cleaning Up Processes.."

    for APM in "${APMS[@]}"; do
        pkill $APM
        echo "Killed $APM"
    done

    echo "Cleanup Finished"
}

get_interface_ip() {
    ip_addr=

    ip_addr=$(ifconfig | grep -F "inet 192." | awk '{print $2}')

    # echo "$ip_addr"
}

spawn_apps() {
    get_interface_ip

    for APM in "${APMS[@]}"; do
        ./"$APM" "$ip_addr" &
        echo "Spawned $APM"
    done
}

collect_process_metrics() {
    while true; do
        sleep 5
    
        for APM in "${APMS[@]}"; do
            app_process_id=$(pgrep "$APM")
            
            CPU=$(ps -p "$app_process_id" -o %cpu= | awk '{print $1}')
            RAM=$(ps -p "$app_process_id" -o %mem= | awk '{print $1}')

            echo "${SECONDS},${CPU},${RAM}" >> "{$APM}_metrics.csv"
        done
    done
}


main() {
    # get_interface_ip
    spawn_apps
    collect_process_metrics &
    wait
}

trap cleanup EXIT

main