#!/bin/bash

APMS=("APM1" "APM2" "APM3" "APM4" "APM5" "APM6")

cleanup(){
    echo "Cleaning Up Processes.."

    for APM in "${APMS[@]}"; do
        pkill $APM
        echo "Killed $APM"
    done

    echo "Cleanup Finished"
}

get_interface_ip(){
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

trap cleanup EXIT

# get_interface_ip
spawn_apps

wait