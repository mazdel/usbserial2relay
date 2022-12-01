#!/usr/bin/bash

HEX_ON='\xA0\x01\x01\xA2'
HEX_OFF='\xA0\x01\x00\xA1'

DEVICE="/dev/ttyUSB0"
STATE="ON"
DIRNAME=$(dirname -- "$0")
LOGFILE="$DIRNAME/state.log"
timestamp=$(date +"%FT%H-%M-%S")

usage() {
    cat <<EOF

Available options :
    -d  : Device tty path. default : /dev/ttyUSB0
    -f  : Logfile. default $(pwd)/state 
    -h  : Show this help
    -l  : get log of last 10 states
    -p  : Switch relay device to the last known state.
    -s  : Device state. default : on
    -r  : Recycle Log to only 500 lines
    

Usage: $0 -f ./state.log -d <path_to_tty_device> -s <on|off> 
       
Example: $0 -d /dev/ttyUSB1 -s on

EOF
    exit 1
}
recycleLog() {
    local lines
    local logs
    lines=$(wc -l <"$LOGFILE")
    if [ "$lines" -gt 500 ]; then
        logs=$(tail -n 500 "$LOGFILE")
        echo -e "$logs" >"$LOGFILE"
    fi
}
sendCmd() {
    local device="$1"
    local switch_act="$2"

    if [ "$switch_act" == "ON" ]; then

        echo -n -e "$HEX_ON" >"$device"
    fi
    if [ "$switch_act" == "OFF" ]; then

        echo -n -e "$HEX_OFF" >"$device"
    fi
}
saveState() {
    local device="$1"
    local state="$2"

    if [ ! -f "${LOGFILE}" ]; then
        touch "${LOGFILE}"
    fi
    state_log="${timestamp}:${device}:${state}"
    echo -e "${state_log}" >>"${LOGFILE}"
    getLog 1

}
getLog() {
    local lines="$1"
    local line=0

    if [ ! -f "${LOGFILE}" ]; then
        echo "$timestamp - can not read logfile : ${LOGFILE}"
        exit 1
    fi

    # shellcheck disable=SC2002
    cat "${LOGFILE}" | tac | while read -r state; do
        # stateArr=(${state//:/ })
        IFS=':' read -r -a stateArr <<<"${state}"

        if [ "${stateArr[1]}" == "${DEVICE}" ]; then
            line=$((line + 1))
            echo "${state}"
        fi
        if [ "$line" == "$lines" ]; then
            break
        fi
    done
}
switch() {
    local device="$1"
    local state="$2"
    local savingState=${3:-"yes"}

    if [ ! -c "$device" ]; then
        echo -e "\n$timestamp - device $device (tty) is not exist!"
        usage
        exit 1
    fi

    case "$state" in
    0 | [Oo][Ff][Ff])

        sendCmd "$device" "OFF"
        if [ "$savingState" == "yes" ]; then
            saveState "$device" "OFF"
        fi
        ;;
    1 | [Oo][Nn])

        sendCmd "$device" "ON"
        if [ "$savingState" == "yes" ]; then
            saveState "$device" "ON"
        fi
        ;;
    *)
        echo -e "\n$timestamp - wrong switch state"
        usage
        exit 1
        ;;
    esac
}
persistent() {
    if [ ! -f "${LOGFILE}" ]; then
        echo -e "\n$timestamp - can not read logfile : ${LOGFILE}\n"
        usage
        exit 1
    fi

    local -r log=$(getLog 1)

    IFS=':' read -r -a state <<<"${log}"
    switch "$DEVICE" "${state[2]}" no
    exit 1
}
main() {
    while getopts hd:s:f:plr flag; do
        case "${flag}" in
        d) DEVICE=${OPTARG} ;;
        f) LOGFILE=${OPTARG} ;;
        h) usage ;;
        l) getLog 10 && exit ;; #TODO <-- make getLog lines more flexible
        p) persistent ;;
        s) STATE=${OPTARG} ;;
        r) recycleLog && exit ;;
        *) usage ;;
        esac
    done
    switch "$DEVICE" "$STATE"
}
main "$@"
