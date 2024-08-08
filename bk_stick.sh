#!/usr/bin/env bash
declare -i test=01 #0 für kein test

shopt -s extglob # ???

# Define a placeholder space character for use in a configuration file
declare -r placeholder_space="#x0020"

# Define associative arrays with desired elements & first allocation
declare -A script_=(
    [dir]=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"/"
    [name]=$(basename "${BASH_SOURCE[0]}")
    [config]='config.xml'
)
declare -A config_elements=(
    [version]=''
    [version_strg]=''
    [lang]=''
    [title_strg]=''
    [menue_strg]=''
    [config_strg]=''
    [editor_prog]=''
    [prog_strg]='meld'
    [home_directory]=''
    [storage_location]=''
    [standard_path]=''
    [remote_path]=''
)
# Define parameter of sync-group-elements
declare -a id
declare -a sync_name
declare -a sync_param
declare -a sync_dir1
declare -a sync_dir2

# Workparameters
declare -i cmdNr=0
declare selection=""

# Function to extract configuration single values from XML
extract_config_values() {
    local -n config_ref=$1

    for element in "${!config_ref[@]}"; do
        # Get only values from conf-file when empty
        if [[ -z ${config_ref["$element"]} ]]; then
            config_ref["$element"]=$(xml_grep "$element" "${script_[config]}" --text_only 2>/dev/null)
        fi
        # Warn if xml-tag is missing or empty
        if [[ -z "${config_ref[$element]}" ]]; then
            [[ $test -gt 0 ]] && echo "Warning (8) for '$element': no value found in config file ${script_[config]}" || \
            message_exit "Warning for '$element': no value in config file ${script_[config]}" 8
            unset ${config_ref[$element]}
        fi
    done
}

# Function to extract configuration arrays from XML
extract_options_values() {
    local element="$1"
    xml_grep $element "${script_[config]}" --text_only
}

# Function to replace defined placeholder from config-file into string
replace_placeholder_strg() {
    local input=$1
    local placeholder=$2
    local replacement=$3
    if [[ $input =~ [$placeholder] ]]; then
        input=$(echo "$input" | sed "s|$placeholder|$replacement|g")
    fi
    echo $input
}

# Function to replace specific placeholders after reading
replace_placeholders() {
    local -n ref=$1
    for ((k = 0; k < ${#id[@]}; k++)); do
        ref[k]=$(replace_placeholder_strg "${ref[k]}" "~" "${config_elements[home_directory]}")
        ref[k]=$(replace_placeholder_strg "${ref[k]}" "\$homeVerz" "${config_elements[home_directory]}")
        ref[k]=$(replace_placeholder_strg "${ref[k]}" "\$stickort" "${config_elements[storage_location]}")
        ref[k]=$(replace_placeholder_strg "${ref[k]}" "\$stdpath" "${config_elements[standard_path]}")
        ref[k]=$(replace_placeholder_strg "${ref[k]}" "\$remotepath" "${config_elements[remote_path]}")
        ref[k]=$(replace_placeholder_strg "${ref[k]}" "$placeholder_space" " ")
    done
}

# Error-window & exit with error number; default-value 1 when missing; wait for response except for err==0
message_exit() {
    local txt=$1
    local err=$2
    err="${err:-1}"
    if [[ $err -gt 0 ]]; then
        zenity --error --width "250" --title ${script_[name]} --text="$txt ($err)"
    fi
    echo $err
}

# Function to check if a USB stick is present
check_stick() {
    local stick_path=$1
    local stick_name=$2
    while true; do
        if ls -A "$stick_path" >/dev/null 2>&1; then
            break
        else
            zenity --question --title ${script_[name]} --width="350" --text="Stick '$stick_name' is missing!\nDo you want to try again? (21)"
            if [ $? -ne 0 ]; then
                exit 21
            fi
        fi
    done
}

###
check_mount2 ( ) { #fct Netzlaufwerk verbunden ? obsolete ???
	local mounted_path=$1
    local lw=$mounted_path"/." #Beliebiges Unterverzeichnis, das immer da ist, zum testen.
        ls -A $lw >/dev/null 2>&1
        if [ $? != 0 ]  
        then
            /home/stefan/prog/bakki/mounti/mounter.sh "$mounted_path"   # ruft mit sudo den mount $1 auf ??? klappt nicht wg path??
            ls -A $lw >/dev/null 2>&1
            if [ $? != 0 ]; then   # falls mounten nicht geklappt -> Abbruch, nicht ewig schleifen
                message_exit "Das hat nicht geklappt!\n'$mounted_path' not mounted." 22
                exit
            fi
        fi
}


# Function to check if a network drive is mounted, and attempt to mount it if not
check_mount() { 
    local mounted_path=$1
    local test_subdir=$mounted_path"/." # Arbitrary subdirectory always present for testing

    # Check if the directory is accessible
    if ! test -d "$test_subdir"; then
        # Attempt to mount the network drive
        /home/stefan/prog/bakki/mounti/mounter.sh "$mounted_path" # ruft mit sudo den mount $1 auf ??? klappt nicht wg path??
        mnt_resp=$?
        echo $mnt_resp"<22"
        
        # Recheck if the directory is accessible after mounting
        if ! test -d "$test_subdir"; then
            message_exit "Failed (#$mnt_resp) to find mounted or to mount \n'$mounted_path'." 22
            exit
        fi
    fi
}

# Function to check if a path exists
check_path() {
	local path=$1			   
	local name=$2

	if [[ $path =~ "/media/" ]]; then 
		check_stick "$path" "$name" 
	fi
	if [[ $path =~ "/mnt/" ]]; then 
		check_mount "$path"
	fi
	if ! test -d "$path"; then
		message_exit "Config-Error: Path \n'$path'\n doesn't exist." 23
		exit
	fi
}
# Function to check availibility of a program
check_prog() {
	local prog_name=$1
	
	if [[ ! -x "$(command -v $prog_name)" ]]; then
		message_exit "Config-Error: program '$prog_name' not found." 74
        exit
    fi  
}

# Display options for selection
display_options () {
    echo .
echo $cmdNr

#for i in "${!config_elements[@]}"; do
    #echo -n "$i -->"
    #echo ${config_elements[$i]}
#done

echo .
# Debugging output
echo "Extracted IDs: ${id[@]}"
echo "Extracted Names: ${sync_name[@]}"
echo "Extracted Param: ${sync_param[@]}"
echo "Extracted dir 1: ${sync_dir1[@]}"
echo "Extracted dir 2: ${sync_dir2[@]}"

echo "Wahl: $selection""<- cmdNr->"$cmdNr"<"
}

unset cmdNr 
# Start of script execution; # Reading arguments from commandline # -c "$cfile" -e geany -n automatisch# -v verbose -h help
while getopts ':c:e:n:vh' OPTION; do
    case "$OPTION" in
        c) script_[config]=${OPTARG} ;;
        e) config_elements[editor_prog]=${OPTARG} ;;
        n) cmdNr=${OPTARG} ;;
        v) test=0 ;;
        ?|h) message_exit "Usage: $(basename $0) [-c Konfiguration.xml] [-e Editor] [-n id] [-v] [-h] \n   " 11; exit $? ;;
    esac
done

# Reading configuration file

# Ensure the configuration file is set, defaulting to "config.xml" if not provided
[[ -z "${script_[config]}" ]] && script_[config]="${script_[config]:-config.xml}"

# Ensure the configuration file exists and is readable
if [ ! -r "${script_[dir]}${script_[config]}" ]; then
    message_exit "Config-Error: Configuration file '${script_[dir]}${script_[config]}' is not readable." 23
    exit
fi

# Call function to extract values
extract_config_values config_elements

# Replace placeholders from config
config_elements[menue_strg]=$(replace_placeholder_strg "${config_elements[menue_strg]}" "\$version" "${config_elements[version]}")
config_elements[menue_strg]=$(replace_placeholder_strg "${config_elements[menue_strg]}" "\$verstxt" "${config_elements[version_strg]}")

# Ensure the editor-prog is set, defaulting to "gedit" if not provided & checking existence
[[ -z "${config_elements[editor_prog]}" ]] && config_elements[editor_prog]="${config_elements[editor_prog]:-gedit}"
check_prog "${config_elements[editor_prog]}"
check_prog "${config_elements[prog_strg]}"

# Extract IDs, names, paths etc.
id=($(extract_options_values 'id'))

for element in "${id[@]}"; do
    if ! [[ "$element" =~ ^[0-9]+$ ]]; then
        message_exit "Config-Error: identifier '$element' no integer." 32
        exit
    fi
done

sync_name=($(extract_options_values 'name')) && replace_placeholders sync_name
sync_param=($(extract_options_values 'param')) && replace_placeholders sync_param
sync_dir1=($(extract_options_values 'dir1')) && replace_placeholders sync_dir1
sync_dir2=($(extract_options_values 'dir2')) && replace_placeholders sync_dir2

# Calculate the number of syncs by dividing the total by the number of sync types
total_sync_elements=$((${#sync_name[@]} + ${#sync_param[@]} + ${#sync_dir1[@]} + ${#sync_dir2[@]}))
num_syncs=$((total_sync_elements / 4))

# Check if the number of syncs matches the number of IDs
if [[ $num_syncs -ne ${#id[@]} ]]; then
    message_exit "Error: Parameter file is not well-filled." 45
    exit
fi

[[ $test -gt 0 ]] && echo "Konfiguration eingelesen! >$cmdNr<\n"
[[ $test -gt 0 ]] && echo "Starte....(Testversion) ......\n"
[[ $test -gt 0 ]] && display_options

# Checking command-number if given
if [[ -n "$cmdNr" ]]; then
    if [[ ${id[@]} =~ "$cmdNr" ]]; then
        selection=$cmdNr
        echo "pups"
    else
        message_exit "Case '$cmdNr' not defined." 66
        exit
    fi
fi

# Loop until a selection is made
while [ -z "$selection" ]; do
    selection=$(zenity --height "350" --width "450" \
        --title "${config_elements[title_strg]}" --text "${config_elements[menue_strg]}" \
        --list --column="Optionen" "${sync_name[@]}" "${config_elements[prog_strg]}" "${config_elements[config_strg]}")
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

[[ $test -gt 0 ]] && echo "Selected: $selection" # Testversion
[[ $test -gt 0 ]] && echo $selection"+++ "$foundIndex" +++"${id[$foundIndex]}"##"${sync_prog[$foundIndex]}"<>""${sync_path[$foundIndex]}${sync_file[$foundIndex]}" #Testoption

# Execution with the selected option
case $selection in
    ${config_elements[prog_strg]})
        command_to_execute="${config_elements[prog_strg]}" #&& check_prog "$command_to_execute"
        $command_to_execute & >/dev/null 2>&1
        ;;
    ${config_elements[config_strg]})
        xfile="${script_[dir]}${script_[config]}e3" 
        check_path "$xfile" "nil"
        command_to_execute="${config_elements[editor_prog]} $xfile" 
        $command_to_execute & >/dev/null 2>&1
        ;;
    ${sync_name[$foundIndex]})
		check_path "${sync_dir1[$foundIndex]}" "${sync_name[$foundIndex]}" 
		check_path "${sync_dir2[$foundIndex]}" "${sync_name[$foundIndex]}"
		command_to_execute="${config_elements[prog_strg]} ${sync_dir1[$foundIndex]} ${sync_dir2[$foundIndex]}" #&& check_prog "$command_to_execute"
		$command_to_execute & >/dev/null 2>&1
        ;;
    *)
        message_exit "Case '$selection' not defined." 99
        exit
        ;;
esac

exit 0

## ab hier junk
