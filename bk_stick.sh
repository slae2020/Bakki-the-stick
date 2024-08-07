#!/usr/bin/env bash
declare -i test=01 #0 für kein test

#shopt -s extglob # ???

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
    [prog_strg]=''
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
declare -i cmdNr=""
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

###
eingesteckt ( ) { #fct  Stick drin ? $1 Ort $2 Name
        ls -a $1 >/dev/null 2>&1

        while [ $? != 0 ] # Fenster wiederholen bis gefunden oder Abbruch
        do
            zenity --question --title="$title" --width="350" --text="Stick '$2' fehlt!\nNoch einen Versuch ?"
            if  [ $? != 0 ]; then
                exit 1
            fi
            [ $? -ne 0 ] && exit 2 # Abbruch
            ls -a $1 >/dev/null 2>&1
        done
}
###
verbunden ( ) { #fct Netzlaufwerk verbunden ?
        lw=$1"/." #Beliebiges Unterverzeichnis, das immer da ist, zum testen.
        ls -A $lw >/dev/null 2>&1
        if [ $? != 0 ]  # s.o
        then
            /home/stefan/perl/mounter.sh $1   # ruft mit sudo den mount $1 auf
            ls -A $lw >/dev/null 2>&1
            if [ $? != 0 ]; then   # falls mounten nicht geklappt -> Abbruch, nicht ewig schleifen
                zenity --info --title="$title" --width="350" --text="Das hat nicht geklappt!\nPasswortfehler?\n'$1' \nfehlt! (exit 22)"
                exit 22
            fi
        fi
}

# Error-window & exit with error number; default-value 1 when missing; wait for response except for err==0
message_exit() {
    local txt=$1
    local err=$2
    err="${err:-1}"
    if [[ $err -gt 0 ]]; then
        zenity --error --title ${script_[name]} --text="$txt ($err)"
    fi
    echo $err
}

# Display options for selection
display_options () {
    echo .
#   echo $(xml_grep 'version' "${script_[config]}" --text_only)

for i in "${!config_elements[@]}"; do
    echo -n "$i -->"
    echo ${config_elements[$i]}
done

echo .
# Debugging output
echo "Extracted IDs: ${id[@]}"
echo "Extracted Names: ${sync_name[@]}"
echo "Extracted Param: ${sync_param[@]}"
echo "Extracted dir 1: ${sync_dir1[@]}"
echo "Extracted dir 2: ${sync_dir2[@]}"

#echo "Wahl: $selection""<-"
}

# Start of script execution; # Reading arguments from commandline # -c "$cfile" -e geany -n automatisch# -v verbose -h help
while getopts ':c:e:n:vh' OPTION; do
    case "$OPTION" in
        c) script_[config]=${OPTARG} ;;
        e) config_elements[editor_prog]=${OPTARG} ;;
        n) cmdNr=${OPTARG} || unset cmdNr ;;
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
if [[ ! -x "$(command -v ${config_elements[editor_prog]})" ]]; then
    message_exit "Config-Error: program '${config_elements[editor_prog]}' not found." 31
    exit
fi

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
    if [ "${id[$i]}" -eq "$selection" ]; then
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
        command_to_execute="${config_elements[prog_strg]}"
        if [[ ! -x "$(command -v $command_to_execute)" ]]; then
            message_exit "Config-Error: program '$command_to_execute' not found." 76
            exit
        else
            $command_to_execute & >/dev/null 2>&1
        fi
        ;;
    ${config_elements[config_strg]})
        xfile="${script_[dir]}${script_[config]}"
        command_to_execute="${config_elements[editor_prog]} $xfile"
        if [[ ! -f $xfile ]]; then
            message_exit "File '$xfile' not found." 77
            exit
        else
            $command_to_execute & >/dev/null 2>&1
        fi
        ;;
    ${sync_name[$foundIndex]})
echo "hie"
        #command_to_execute="${template_prog[$foundIndex]} ${template_path[$foundIndex]}${template_file[$foundIndex]}"
        #if [[ ${template_file[$foundIndex]} =~ ".ott" && ! -r "${template_path[$foundIndex]}${template_file[$foundIndex]}" ]]; then
            #message_exit "'${template_path[$foundIndex]}${template_file[$foundIndex]}' \n not found." 05
            #exit $?
        #fi
        #$command_to_execute & >/dev/null 2>&1
        ;;

    ${optName[$index]}) # obsolete???
        grep -q "/media/" <<<"${dir1[$index]}" && eingesteckt "${dir1[$index]}" "${optName[$index]}"
        grep -q "/media/" <<<"${dir2[$index]}" && eingesteckt "${dir2[$index]}" "${optName[$index]}"
        grep -q "/mnt/"   <<<"${dir1[$index]}" && verbunden "${dir1[$index]}"
        grep -q "/mnt/"   <<<"${dir2[$index]}" && verbunden "${dir2[$index]}"
        ###
        [[ ${dir1[$index]} =~ [\/] || ${dir2[$index]} =~ [\/] ]] &&
        meld ${dir1[$index]} ${dir2[$index]} >/dev/null 2>&1  || echo "Falsche(r) Ordner für $optName[$index] '"${dir1[$index]}"'||'"${dir2[$index]}"' / (Fehler 66)"
        ;;
    *)
        message_exit "Case '$selection' not defined." 99
        exit
        ;;
esac

exit 0

## ab hier junk
