#!/usr/bin/env bash

source configreader.sh
source tester.sh

declare -i is_test_mode=1  # 1 for test mode, 0 for normal operation

# Start of script execution; # Reading arguments from commandline # -c "$cfile" -e geany -n automatisch# -v verbose -h help
while getopts ':c:e:n:vh' OPTION; do
    case "$OPTION" in
        c) script_[config]=${OPTARG} ;;
        e) config_elements[editor_prog]=${OPTARG} ;;
        n) cmdNr=${OPTARG} ;;
        v) is_test_mode=0 ;;
        ?|h) message_exit "Usage: $(basename $0) [-c Konfiguration.xml] [-e Editor] [-n id] [-v] [-h] \n" 11; exit ;;
    esac
done

read_configuration "${script_[config]}"

# Checking command-number if given & defined
if [[ -n "$cmdNr" ]]; then
    if [[ ${id[@]} =~ "$cmdNr" ]]; then
        selection=$cmdNr
    else
        message_exit "Error with commandline: Case '$cmdNr' not defined." 66
        exit
    fi
fi

# Loop until a selection is made
while [ -z "$selection" ]; do
	setdisplay 350 450
    selection=$(ask_to_choose "${config_elements[title_strg]}" "${config_elements[menue_strg]}" \
			""    opti1 "${config_elements[prog_strg]}" "${config_elements[config_strg]}")  # "" oder Optionen oder Options ???
    if [[ $selection == $is_cancel ]]; then
        message_exit "Dialog canceled by user." 0       
        exit 
    fi
done
resetdisplay

# Match selectedIndex to selection
for i in "${!opti1[@]}"; do
    if [[ "${opti1[$i]}" == "$selection" ]]; then
        selectedIndex=$i
        break
    fi
    if [ "${id[$i]}" -eq "$selection" >/dev/null 2>&1 ]; then
        selectedIndex=$i
        break
    fi
done

# Check if selectedIndex is set and within bounds (to make sure)
if [[ -n $selectedIndex && selectedIndex -ge 0 && selectedIndex -lt ${#opti1[@]} ]]; then
    selection=${opti1[$selectedIndex]}
fi

[[ $is_test_mode -gt 0 ]] && echo "Selected: $selection" # Testversion
[[ $is_test_mode -gt 0 ]] && echo $selection"+++ "$selectedIndex" +++"${id[$selectedIndex]}"##"${sync_prog[$selectedIndex]}"<>""${sync_path[$selectedIndex]}${sync_file[$selectedIndex]}" #Testoption

# Execution with the selected option
case $selection in
    ${config_elements[prog_strg]})
        command_to_execute="${config_elements[prog_strg]}" 
        eval $command_to_execute & >/dev/null 2>&1
        ;;
    ${config_elements[config_strg]})
        xfile="${script_[dir]}${script_[config]}"
        check_path "$xfile" "nil"
        command_to_execute="${config_elements[editor_prog]} $xfile"
        eval $command_to_execute & >/dev/null 2>&1
        ;;
    ${opti1[$selectedIndex]})
        check_path "${opti2[$selectedIndex]}" "${opti1[$selectedIndex]}"
        check_path "${opti3[$selectedIndex]}" "${opti1[$selectedIndex]}"
        command_to_execute="${config_elements[prog_strg]} ${opti2[$selectedIndex]} ${opti3[$selectedIndex]}" 
        eval $command_to_execute & >/dev/null 2>&1
        ;;
    *)
        message_exit "General error: case '$selection' not defined." 99
        exit
        ;;
esac

exit 0

## ab hier junk


