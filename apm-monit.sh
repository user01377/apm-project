#!/bin/bash

get_interface_ip(){
    ip_addr=

    ip_addr=$(ifconfig | grep -F "inet 192." | awk '{print $2}')

    # echo "$ip_addr"
}

spawn_apps() {
    get_interface_ip

    local APMS=("APM1" "APM2" "APM3" "APM4" "APM5" "APM6")

    for APM in "${APMS[@]}"; do
        ./"$APM" "$ip_addr" &
    done
}

# get_interface_ip
spawn_apps