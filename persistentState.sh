#!/usr/bin/bash

HEX_ON='\xA0\x01\x01\xA2'
HEX_OFF='\xA0\x01\x00\xA1'

DEVICE=${1}
SLEEP=${2:-"1"}

getLog(){
    local lines="$1"
    local line=0
    cat ./state | tac | while read state; do
        stateArr=(${state//:/ })
        
        if [ "${stateArr[1]}" == "${DEVICE}" ];then
            line=$(($line+1))
            echo ${state};
        fi
        if [ "$line" == "$lines" ];then
            break
        fi        
    done;
}
persistent(){
    latestState=$(getLog 1)
    echo $latestState;
    local stateArr=(${latestState//:/ })
    local switch_act=${stateArr[2]}

    if [ "$switch_act" == "ON" ]; then
        echo -n -e "$HEX_ON" > "$DEVICE"
    fi
    if [ "$switch_act" == "OFF" ]; then
        echo -n -e "$HEX_OFF" > "$DEVICE"
    fi
    sleep ${SLEEP}
    #TODO : lanjutin ini
    # persistent 2>&1
}
main(){
    if [ ! -f "$DEVICE" ];then
        echo "device $DEVICE not found"
        exit 1
    fi
    persistent
}
main