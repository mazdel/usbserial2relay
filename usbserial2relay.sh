#!/usr/bin/bash

HEX_ON='\xA0\x01\x01\xA2'
HEX_OFF='\xA0\x01\x00\xA1'

DEVICE=${1:-"/dev/ttyUSB0"}
STATE=${2:-"1"}
PERSISTENT=${3:-"NO"}

usage() {
	cat <<EOF

Usage: $0 <path_to_tty_device> <0|1>
       0: Turn the Relay OFF
       1: Turn the Relay ON

Example: $0 /dev/ttyUSB1 0

EOF
}
sendCmd(){
    local switch_act="$1"
    if [ "$switch_act" == "ON" ]; then
        echo -n -e "$HEX_ON" > "$DEVICE"
    fi
    if [ "$switch_act" == "OFF" ]; then
        echo -n -e "$HEX_OFF" > "$DEVICE"
    fi
}
saveState(){
    local state="$1"
    timestamp=`date +"%FT%H-%M-%S"`
    if [ ! -f "./state" ];then
        touch ./state
    fi
    state_log="${timestamp}:${DEVICE}:${state}"
    echo -e "${state_log}" >> ./state
    getLog 1
    # if [ "${PERSISTENT}" == 'persistent' ];then
    # 
    # fi
    #TODO : lanjutin ini
}
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
switch(){
    case "$STATE" in
        0|[Oo][Ff][Ff])
            sendCmd "OFF"
            saveState "OFF"
            
            ;;
        1|[Oo][Nn])
            sendCmd "ON"
            saveState "ON"
            
            ;;
        *)
            usage
            exit 1
            ;;
    esac
}
main(){
    if [ "$DEVICE" == "-h" ];then
        usage
        exit 1
    fi
    if [ ! -c "$DEVICE" ];then
        echo "device (tty) is not exist"
        usage
        exit 1
    fi
    switch
}
main