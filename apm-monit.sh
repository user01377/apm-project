#!/bin/bash

get_interface_ip(){
    ip_addr=

    ip_addr=$(ifconfig | grep -F "inet 192." | awk '{print $2}')

    echo "$ip_addr"
}

spawn_apps(){

}

get_interface_ip