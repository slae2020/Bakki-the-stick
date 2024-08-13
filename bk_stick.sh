#!/usr/bin/env bash

source declarations.sh 
source messenge.sh
source configreader.sh
source checker.sh

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

check_configname
## Ensure the configuration file is set, defaulting to "config.xml" if not provided
#[[ -z "${script_[config]}" ]] && script_[config]="${script_[config]:-config.xml}"
#[[ "$(dirname "${script_[config]}")"  == "." ]] && script_[config]="${script_[dir]}${script_[config]}"
#check_path "${script_[config]}"

# Reading configuration file
#[[ $is_test_mode -gt 0 ]] && zenity --notification  --window-icon="info" --title ${script_[name]} \
                                #--text="${script_[name]}\nReading configuration file \n\n${script_[config]}." --timeout=1 &  #???

read_configuration

# Call function to extract values
#extract_config_values config_elements

# Replace placeholders from config
#config_elements[menue_strg]=$(replace_placeholder_strg "${config_elements[menue_strg]}" "\$version" "${config_elements[version]}")
#config_elements[menue_strg]=$(replace_placeholder_strg "${config_elements[menue_strg]}" "\$verstxt" "${config_elements[version_strg]}")

## Ensure the editor-prog is set, defaulting to "gedit" if not provided & checking existence
#[[ -z "${config_elements[editor_prog]}" ]] && config_elements[editor_prog]="${config_elements[editor_prog]:-gedit}"
#check_prog "${config_elements[editor_prog]}"
#check_prog "${config_elements[prog_strg]}"

# Extract IDs, names, paths etc.
#id=($(extract_options_values 'id'))

#read_identifier

## Check if id are integers
#for element in "${id[@]}"; do
    #if ! [[ "$element" =~ ^[0-9]+$ ]]; then
        #message_exit "Config-Error: identifier '$element' in config-file has to be an integer!" 32
        #exit
    #fi
#done

#read_options opti1
read_alloptions

#sync_name=($(extract_options_values 'name')) && replace_placeholders sync_name
#sync_param=($(extract_options_values 'param')) && replace_placeholders sync_param
#sync_dir1=($(extract_options_values 'dir1')) && replace_placeholders sync_dir1
#sync_dir2=($(extract_options_values 'dir2')) && replace_placeholders sync_dir2

## Check if the number of syncs matches the number of IDs
#num_param=$((${#sync_name[@]} + ${#sync_param[@]} + ${#sync_dir1[@]} + ${#sync_dir2[@]} ))
#rate=$(( $num_param % $num_elements ))
#if [ $rate -ne 0 ]; then
    #message_exit "Missing data: Config-file with '$num_param MOD $num_sync_elements' item(s) is not well-filled." 45
    #exit
#fi

done_configuration

# Checking command-number if given
if [[ -n "$cmdNr" ]]; then
    if [[ ${id[@]} =~ "$cmdNr" ]]; then
        selection=$cmdNr
    else
        message_exit "Error with commandline: Case '$cmdNr' not defined." 66
        exit
    fi
fi

# Loop until a selection is made
tt="${opti1[@]}"
while [ -z "$selection" ]; do
    selection=$(zenity --height "350" --width "450" \
        --title "${config_elements[title_strg]}" --text "${config_elements[menue_strg]}" \
        --list --column="Optionen" "${opti1[@]}" "${config_elements[prog_strg]}" "${config_elements[config_strg]}")
    if [ $? -ne 0 ]; then
        message_exit "Dialog canceled by user." 0
        exit
    fi
done

# Match foundIndex to selection
for i in "${!sync_name[@]}"; do
    if [[ "${sync_name[$i]}" == "$selection" ]]; then
        foundIndex=$i
        break
    fi
    if [ "${id[$i]}" -eq "$selection" >/dev/null 2>&1 ]; then
        foundIndex=$i
        break
    fi
done

# Check if foundIndex is set and within bounds (to make sure)
if [[ -n $foundIndex && foundIndex -ge 0 && foundIndex -lt ${#sync_name[@]} ]]; then
    selection=${sync_name[$foundIndex]}
fi

[[ $is_test_mode -gt 0 ]] && echo "Selected: $selection" # Testversion
[[ $is_test_mode -gt 0 ]] && echo $selection"+++ "$foundIndex" +++"${id[$foundIndex]}"##"${sync_prog[$foundIndex]}"<>""${sync_path[$foundIndex]}${sync_file[$foundIndex]}" #Testoption

# Execution with the selected option
case $selection in
    ${config_elements[prog_strg]})
        command_to_execute="${config_elements[prog_strg]}" #&& check_prog "$command_to_execute"
        eval $command_to_execute & >/dev/null 2>&1
        ;;
    ${config_elements[config_strg]})
        xfile="${script_[dir]}${script_[config]}"
        check_path "$xfile" "nil"
        command_to_execute="${config_elements[editor_prog]} $xfile"
        eval $command_to_execute & >/dev/null 2>&1
        ;;
    ${sync_name[$foundIndex]})
        check_path "${sync_dir1[$foundIndex]}" "${sync_name[$foundIndex]}"
        check_path "${sync_dir2[$foundIndex]}" "${sync_name[$foundIndex]}"
        command_to_execute="${config_elements[prog_strg]} ${sync_dir1[$foundIndex]} ${sync_dir2[$foundIndex]}" #&& check_prog "$command_to_execute"
        eval $command_to_execute & >/dev/null 2>&1
        ;;
    *)
        message_exit "General error: case '$selection' not defined." 99
        exit
        ;;
esac

exit 0

## ab hier junk


