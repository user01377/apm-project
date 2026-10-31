#!/bin/bash

APMS=("APM1" "APM2" "APM3" "APM4" "APM5" "APM6")

# cleanup function that runs when the trap is executed
cleanup() {
    echo -e "\nCleaning Up Processes.."

    for APM in "${APMS[@]}"; do
        pkill $APM
        echo "Killed $APM"
    done

    echo "Cleanup Finished"
}

# helper func which gets current ip of machine, used for starting the scripts
get_interface_ip() {
    # ip_addr=

    ip_addr=$(ifconfig | grep -F "inet 192." | awk '{print $2}')

    # echo "$ip_addr"
}

# spawns all applications in the APMS array
spawn_apps() {
    get_interface_ip

    for APM in "${APMS[@]}"; do
        ./"$APM" "$ip_addr" &
        echo "Spawned $APM"
    done
}

# function to collect process level data. Writes all CSV files to /process_data directory located in the directory where this script is ran from
collect_process_metrics() {
    mkdir -p "./process_data"

    for APM in "${APMS[@]}"; do
        echo "Seconds,CPU,RAM" > "./process_data/${APM}_metrics.csv"
    done

    while true; do
        for APM in "${APMS[@]}"; do
            app_process_id=$(pgrep "$APM")
            
            CPU=$(ps -p "$app_process_id" -o %cpu= | awk '{print $1}')
            RAM=$(ps -p "$app_process_id" -o %mem= | awk '{print $1}')

            echo "${SECONDS},${CPU},${RAM}" >> "./process_data/${APM}_metrics.csv"
        done

        sleep 5
    done
}

collect_system_metrics() {
    mkdir -p "./system_data"
    echo "Seconds,DiskWrites(KB/s),AvailableDisk(GB)" > "./system_data/system_metrics.csv"

    while true; do
        # get disk write statistic from the primary drive (sda)
        DISK_WRITES=$(iostat sda | grep sda | awk '{print $4}')
        if [ -z "$DISK_WRITES" ]; then
            DISK_WRITES="0"
        fi

        # get available disk capacity
        AVAIL_DISK=$(df -BG . | awk 'NR==2 {print $4}')
        if [ -z "$AVAIL_DISK" ]; then
            AVAIL_DISK="0"
        fi

        echo "${SECONDS},${DISK_WRITES},${AVAIL_DISK}" >> "./system_data/system_metrics.csv"

        sleep 5
    done
}

main() {
    spawn_apps
    collect_process_metrics &
    collect_system_metrics &
    wait
}

trap cleanup EXIT

main