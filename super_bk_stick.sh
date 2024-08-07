#!/bin/bash

#askcodi 240805

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
SCRIPT_NAME="/bk_stick.sh"

# Check if the script exists and is executable
if [[ ! -f "$SCRIPT_DIR$SCRIPT_NAME" ]]; then
    echo "Error: Script $SCRIPT_DIR$SCRIPT_NAME not found."
    exit 1
fi
if [[ ! -x "$SCRIPT_DIR$SCRIPT_NAME" ]]; then
    echo "Error: Script $SCRIPT_DIR$SCRIPT_NAME is not executable."
    exit 1
fi

run_script() {
    local args="$1"
    eval "$SCRIPT_DIR$SCRIPT_NAME $args" &
}

run_script "-n 8"
run_script "-n 28"
# Uncomment and modify if needed
# run_script "-n 0"

exit 0



### ab hier junk

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
SCRIPT_NAME="/bk_stick.sh"
#echo -e $SCRIPT_DIR$SCRIPT_NAME # TEstversion

eval "$SCRIPT_DIR$SCRIPT_NAME '-n 8' " &

eval "$SCRIPT_DIR$SCRIPT_NAME '-n 28' " &

#eval "$SCRIPT_DIR$SCRIPT_NAME '-n 0' " &

exit 0



#echo "The script you are running has:"
#echo "basename: [$(basename "$0")]"
#echo "dirname : [$(dirname "$0")]"
#echo "pwd     : [$(pwd)]"
