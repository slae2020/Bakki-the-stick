#!/bin/bash
#askcodi 240805

. /home/stefan/prog/bakki/Bakki-the-stick/dialog.sh

# Start of script execution; # Reading arguments from commandline # -c "$cfile" -e geany -n automatisch# -v verbose -h help
while getopts ':c:m:s:vh' OPTION; do
    case "$OPTION" in
        c) config_file=${OPTARG} ;;
        m) list=${OPTARG} ;;
        s) SCRIPT_NAME="//"${OPTARG}
           SCRIPT_NAME=${SCRIPT_NAME/\/\//\/};;  # doppel // check
        v) verbose="on" ;;
        ?|h) message_exit "Usage: $(basename $0) [-s script(.sh)] [-c Konfiguration.xml] [-e Editor] [-m id-id-id] [-v] [-h] \n" 11 ;;
    esac
done

# Use a loop with regex to "bash split string into array"
while [[ $list =~ ([a-zA-Z0-9]+) ]]; do
    myvar+=("${BASH_REMATCH[1]}")        # Adding matched word to the array
    list=${list#*${BASH_REMATCH[1]}} # Removing the matched part from the beginning of the string
done

# Corrections
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
if [[ ! $SCRIPT_NAME =~ (.sh)$ ]]; then
    SCRIPT_NAME+=".sh"
fi

# Check if the script exists and is executable
if [[ ! -f "$SCRIPT_DIR$SCRIPT_NAME" ]]; then
    message_exit "Error: Script $SCRIPT_DIR$SCRIPT_NAME not found." 1
fi
if [[ ! -x "$SCRIPT_DIR$SCRIPT_NAME" ]]; then
    message_exit "Error: Script $SCRIPT_DIR$SCRIPT_NAME is not executable." 1
fi

# Mainloop
for ((i = 0; i < ${#myvar[@]}; i++)); do
	if ! [[ "${myvar[i]}" =~ ^[0-9]+$ ]]; then
		message_notification "Config-Error: '-m ${myvar[i]}' has to be an integer!" 1
    else
		command_to_execute="$SCRIPT_DIR$SCRIPT_NAME -n ${myvar[i]}"
		if [[ -n $verbose ]]; then
			command_to_execute+=" -v "
		fi
		if [[ -n $config_file ]]; then
			command_to_execute+=" -c $config_file"
		fi
	# Execution!
echo .
echo "$command_to_execute" 
    eval "$command_to_execute" &
    fi
done

exit 0


### ab hier junk

echo .
echo $command_to_execute


#run_script "-n 01 -v -c /home/stefan/prog/bakki/Bakki-the-stick/config0906.xml"
#run_script "-n 03 -v -c /home/stefan/prog/bakki/Bakki-the-stick/config0906.xml"
#run_script "-n 08 -v -c /home/stefan/prog/bakki/Bakki-the-stick/config0906.xml"
# Uncomment and modify if needed
# run_script "-n 0"





SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
SCRIPT_NAME="/bk_stick.sh"
echo -e $SCRIPT_DIR$SCRIPT_NAME # TEstversion


eval "$SCRIPT_DIR$SCRIPT_NAME '-n 8' " &

eval "$SCRIPT_DIR$SCRIPT_NAME '-n 28' " &

#eval "$SCRIPT_DIR$SCRIPT_NAME '-n 0' " &

exit 0



#echo "The script you are running has:"
#echo "basename: [$(basename "$0")]"
#echo "dirname : [$(dirname "$0")]"
#echo "pwd     : [$(pwd)]"
