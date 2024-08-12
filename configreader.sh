#!/usr/bin/env bash

source declarations.sh
source checker.sh
source tester.sh

# Define a placeholder space character for use in a configuration file
declare -r placeholder_space="#x0020"

# Define standardnames
declare -r config_stdname="config.xml"

# Define associative arrays with desired elements & first allocation
declare -A script_=(
    [dir]=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"/"    # hier auch v
    [name]=$(basename "${BASH_SOURCE[0]}")                                            #??? configreader.sh?
    [config]="$config_stdname"
)
declare -A config_elements=(
    [version]=''
    [version_strg]=''
    [lang]=''
    [title_strg]=''
    [menue_strg]=''
    [config_strg]=''
    [editor_prog]=''
    [prog_strg]='meld'   #????
    [home_directory]=''
    [storage_location]=''
    [standard_path]=''
    [remote_path]=''
)

# Function to extract configuration single values one by one
extract_config_values() {
    local -n config_ref=$1

    for name_element in "${!config_ref[@]}"; do
        # Get only values from conf-file when empty
        if [[ -z ${config_ref["$name_element"]} ]]; then
            config_ref["$name_element"]=$(xml_grep "$name_element" "${script_[config]}" --text_only 2>/dev/null)
        fi
        # Warn if xml-tag is missing or empty
        if [[ -z "${config_ref[$name_element]}" ]]; then
            [[ $is_test_mode -gt 0 ]] && echo "Warning (8) for '$name_element': no value from config file \n${script_[config]}" || \
            message_exit "Warning for '$name_element': no value from config file \n${script_[config]}" 8
            unset ${config_ref[$name_element]}
        fi
    done
}

# Function to extract all entries in associated arrays with name_option
extract_options_values() {
    local name_option="$1"
    xml_grep $name_option "${script_[config]}" --text_only 
}

# Function to extract all entries in associated arrays with name_option
extract_options_values2() {
    local name_option="$1"
    xml_grep $name_option "${script_[config]}" --text_only 
    #echo "%&"  # ???
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


# Function to start 

# Ensure the configuration file is set, defaulting to "$config_stdname" if not provided
check_configname() {
	[[ -z "${script_[config]}" ]] && script_[config]="${script_[config]:-$config_stdname}"
	[[ "$(dirname "${script_[config]}")"  == "." ]] && script_[config]="${script_[dir]}${script_[config]}"
	check_path "${script_[config]}"
}

# Reading configuration file
read_configuration() {
	[[ $is_test_mode -gt 0 ]] && zenity --notification  --window-icon="info" --title ${script_[name]} \
                                --text="${script_[name]}\nReading configuration file \n\n${script_[config]}." --timeout=1 &  #???
                                
	# Call function to extract values
	extract_config_values config_elements
	
	# Replace placeholders from config
	config_elements[menue_strg]=$(replace_placeholder_strg "${config_elements[menue_strg]}" "\$version" "${config_elements[version]}")
	config_elements[menue_strg]=$(replace_placeholder_strg "${config_elements[menue_strg]}" "\$verstxt" "${config_elements[version_strg]}")
	
	# Ensure the editor-prog is set, defaulting to "gedit" if not provided & checking existence
	[[ -z "${config_elements[editor_prog]}" ]] && config_elements[editor_prog]="${config_elements[editor_prog]:-gedit}"
	check_prog "${config_elements[editor_prog]}"
	check_prog "${config_elements[prog_strg]}"
}

# Extract IDs
read_identifier(){
	id=($(extract_options_values 'id'))

	# Check if id are integers
	for element in "${id[@]}"; do
		if ! [[ "$element" =~ ^[0-9]+$ ]]; then
			message_exit "Config-Error: identifier '$element' in config-file has to be an integer!" 32
			exit
		fi
	done
}

# Extract names, paths etc.
read_options() {
	for element in "${!option[@]}"; do
		#echo "$element"
		option["$element"]=$(extract_options_values2 "$element")
		# replace_placeholders option["$element"]  # ???
	done
	
#sync_name=($(extract_options_values 'name')) && replace_placeholders sync_name
#options[sync_name]=$(extract_options_values2 'name')
#sync_param=($(extract_options_values 'param')) && replace_placeholders sync_param
#sync_dir1=($(extract_options_values 'dir1')) && replace_placeholders sync_dir1
#sync_dir2=($(extract_options_values 'dir2')) && replace_placeholders sync_dir2

	# Check if the number of syncs matches the number of IDs    check spaeter???
#num_param=$((${#sync_name[@]} + ${#sync_param[@]} + ${#sync_dir1[@]} + ${#sync_dir2[@]} ))
#rate=$(( $num_param % $num_elements ))
#if [ $rate -ne 0 ]; then
    #message_exit "Missing data: Config-file with '$num_param MOD $num_sync_elements' item(s) is not well-filled." 45
    #exit
#fi
}

# Reading configuration completed
done_configuration() {
[[ $is_test_mode -gt 0 ]] && echo "Konfiguration eingelesen! >$cmdNr<\n"
[[ $is_test_mode -gt 0 ]] && echo "Starte....(Testversion) ......\n"
[[ $is_test_mode -gt 0 ]] && display_options 5
[[ $is_test_mode -gt 0 ]] && zenity --notification  --window-icon="info" --title ${script_[name]} \
                                --text="${script_[name]}\nConfiguration loaded!. >$cmdNr<\n" --timeout=1 &  #???
}



return

# exex test
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
is_test_mode=1

check_configname
read_configuration

read_identifier
read_options

done_configuration

exit 0
