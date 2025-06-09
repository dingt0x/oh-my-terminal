#!/bin/bash

add_route(){
    ROUTE="
    10.202.0.0/22,192.168.130.202
    10.203.0.0/22,192.168.130.203
    "

    echo "$ROUTE" | while read -r route_items; do
        dest=${route_items%%,*}
        gw=${route_items##*,}
        if [ "${dest:0:1}" = "" ] || [ "${dest:0:1}" = "#" ]; then
          continue
        fi

        if ip route | grep -c "$dest" > /dev/null 2>&1; then
          continue
        fi

        if ! (ip addr |grep "${gw%.*}" > /dev/null 2>&1); then
            continue
        fi

        if  (ip addr |grep "${gw}" > /dev/null 2>&1); then
            continue
        fi

        sudo ip route add "$dest" via "$gw"

    done
}

add_route
