#!/bin/bash

add_route(){
    ROUTE="
    10.202.0.0/22,192.168.130.202
    10.203.0.0/22,192.168.130.203
    "

    echo "$ROUTE" | while read -r route_items; do
        dest=${route_items%%,*}
        gw=${route_items##*,}
        echo "dest $dest" 
        echo "gw $gw" 
        # Ignore empty lines or comments
        if [ "${dest:0:1}" = "" ] || [ "${dest:0:1}" = "#" ]; then
            continue
        fi

        # Ignore if existing
        if ip route | grep -c "$dest" > /dev/null 2>&1; then
            continue
        fi

        # Ignore if no subnet
        if ! (ip addr |grep "${gw%.*}" > /dev/null 2>&1); then
            continue
        fi

        # Ignore if gw is self
        if  (ip addr |grep "${gw}" > /dev/null 2>&1); then
            continue
        fi

        sudo ip route add "$dest" via "$gw"

    done
}

add_route
