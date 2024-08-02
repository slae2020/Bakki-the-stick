#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
SCRIPT_NAME="/bk_stick.sh"
#echo -e $SCRIPT_DIR$SCRIPT_NAME # TEstversion

eval "$SCRIPT_DIR$SCRIPT_NAME '-n 8' " &

eval "$SCRIPT_DIR$SCRIPT_NAME '-n 28' " &

#eval "$SCRIPT_DIR$SCRIPT_NAME '-n 0' " &

exit 0

### ab hier junk

#echo "The script you are running has:"
#echo "basename: [$(basename "$0")]"
#echo "dirname : [$(dirname "$0")]"
#echo "pwd     : [$(pwd)]"
