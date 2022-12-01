# usbserial2relay
tested on LCUS-1 5V USB Relay Module CH340 USB Control Switch in LINUX

### Main problem
this LCUS-1 5V USB Relay Module CH340 doesn't have a way to remember it's last state so the state will change to its default when the power loss

## Usage

```
Usage: ./usbserial2relay.sh -f ./state.log -d <path_to_tty_device> -s <on|off> 
```
```
Example: ./usbserial2relay.sh -d /dev/ttyUSB1 -s on
```
Available options :
```
-d  : Device tty path. default : /dev/ttyUSB0
-f  : Logfile. default $(pwd)/state 
-h  : Show this help
-l  : get log of last 10 states
-p  : Switch relay device to the last known state.
-s  : Device state. default : on
-r  : Recycle Log to only 500 lines
```
