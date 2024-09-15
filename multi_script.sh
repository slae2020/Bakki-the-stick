#!/bin/bash

## "./%f"     -m 02 -s bk_stick  -c /home/stefan/prog/bakki/Bakki-the-stick/config0906.xml
#"./%f"   -v -m 02 -s bk_stick  -c ~/prog/bakki/Bakki-the-stick/config0906.xml

# Path_vari [0] path  [1] name
declare -a SCRIPT_=""
declare -a PROG_=""
declare -a CONFIG_=""

split_path() {
    path=$1
    local -n file=$2

    if [[ $path =~ "/" ]]; then
        file[0]=${path%\/*}"/"
    fi
    file[1]=${path##*\/}
}

echo_exit() {
    echo "$1"
    exit "$2"
}

# Start of script execution;
# Reading arguments from commandline #- s script(.sh) ==PROG -c "$cfile"==CONFIG  -m automatische -v verbose -h help
SCRIPT_[0]=$(cd -- "$(dirname -- "$(readlink -f "$0")")" &> /dev/null && pwd)"/"
SCRIPT_[1]=$(basename "$(readlink -f "$0")" )
while getopts ':c:m:s:vh' OPTION; do
    case "$OPTION" in
        s)  split_path "${OPTARG}" PROG_ ;;
        c)  split_path "${OPTARG}" CONFIG_ ;;
        m)  list=${OPTARG} ;;
        v)  verbose="on" ;;
        ?|h)
            echo_exit "Usage: $(basename $0) [-s script(.sh)] [-c Konfiguration.xml] [-m id-id-id] [-v] [-h] \n" 11 ;;  #??
    esac
done

# Corrections
if [[ ! $PROG_[1] =~ (.sh)$ ]]; then
    PROG_[1]+=".sh"
fi
if [[ -z $PROG_[0] ]]; then
    PROG_[0]=${SCRIPT_[0]}
fi
if [[ -z $CONFIG_[0] ]]; then
    CONFIG_[0]=${SCRIPT_[0]}
fi

# Check if the script exists and is executable
if [[ ! -f "${PROG_[0]}${PROG_[1]}" ]]; then
    echo_exit "Error: Script '${PROG_[0]}${PROG_[1]}' not found." 1
fi
if [[ ! -x "${PROG_[0]}${PROG_[1]}" ]]; then
    echo_exit "Error: Script '${PROG_[0]}${PROG_[1]}' is not executable." 1
fi

# Use a loop with regex to "bash split string into array"
while [[ $list =~ ([a-zA-Z0-9]+) ]]; do
    myvar+=("${BASH_REMATCH[1]}")        # Adding matched word to the array
    list=${list#*${BASH_REMATCH[1]}} # Removing the matched part from the beginning of the string
done


# Mainloop
for ((i = 0; i < ${#myvar[@]}; i++)); do
    if ! [[ "${myvar[i]}" =~ ^[0-9]+$ ]]; then
        message_notification "Config-Error: '-m ${myvar[i]}' has to be an integer!" 1
    else
        command_to_execute="${PROG_[0]}${PROG_[1]} -n ${myvar[i]}"
        if [[ -n $verbose ]]; then
            command_to_execute+=" -v "
        fi
        if [[ -n ${CONFIG_[1]} ]]; then
            command_to_execute+=" -c ${CONFIG_[0]}${CONFIG_[1]}"
        fi
    # Execution!
#echo .
#echo "$command_to_execute"
    eval "$command_to_execute" &
    fi
done

exit 0


### ab hier junk



echo "==="
declare -p SCRIPT_
declare -p PROG_
declare -p CONFIG_
echo "==="

echo .
echo $command_to_execute

#echo "The script you are running has:"
#echo "basename: [$(basename "$0")]"
#echo "dirname : [$(dirname "$0")]"
#echo "pwd     : [$(pwd)]"
