#!/usr/bin/env bash

source declarations.sh
source checker.sh
source tester.sh

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
#echo "ksksk""${script_[config]}"
    #echo $(xml_grep $name_option "${script_[config]}" --text_only | sed -e 's#n#ÖÖÖÖÖ#g')
    #echo $(xml_grep $name_option "${script_[config]}" --text_only )
    xml_grep $name_option "${script_[config]}" --text_only
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

# Extract IDs
read_identifier(){
	local -n option_ref=$1

    option_ref=($(extract_options_values 'id'))

    # Check if found entries are integers
    for element in "${option_ref[@]}"; do
        if ! [[ "$element" =~ ^[0-9]+$ ]]; then
            message_exit "Config-Error: entry '$element' in config-file has to be an integer!" 32
            exit
        fi
    done
}

# Extract options like names, paths etc.
read_options() {
    local -n option_ref=$1

    if [[ -n ${option_ref[0]} ]]; then
        option_ref=($(extract_options_values ${option_ref[0]}))
        replace_placeholders option_ref
    fi
}

# Extract elements <>''
count_options() {
    local -n option_ref=$1
    count=$2

    if [[ -n ${option_ref[0]} ]]; then
        count=$(( $count + ${#option_ref[@]} ))
    fi
    echo $count
}

# Extract id, names, paths etc.
read_alloptions() {
    local -i num_options=0
    rate=0

    read_identifier id
    rate=$(( $(count_options id 0) ))
    if [ $rate -eq 0 ]; then
        message_exit "Missing data: Config-file '$1' has no item." 44
    fi

    read_options opti1
    num_options=$(( $(count_options opti1 $num_options) ))
    read_options opti2
    num_options=$(( $(count_options opti2 $num_options) ))
    read_options opti3
    num_options=$(( $(count_options opti3 $num_options) ))
    read_options opti4
    num_options=$(( $(count_options opti4 $num_options) ))
    read_options opti5
    num_options=$(( $(count_options opti5 $num_options) ))
    read_options opti6
    num_options=$(( $(count_options opti6 $num_options) ))
    read_options opti7
    num_options=$(( $(count_options opti7 $num_options) ))


    # Check correct count of options
    rate=$(( $num_options % $num_elements ))
    if [ $rate -ne 0 ]; then
        message_exit "Missing data: Config-file '$1' with '$num_options MOD $num_elements' item(s) is not well-filled." 45
    fi
}

# Reading configuration completed
done_configuration() {
[[ $is_test_mode -gt 0 ]] && echo "Konfiguration eingelesen! >$cmdNr<\n"
[[ $is_test_mode -gt 0 ]] && echo "Starte....${script_[name]} (Testversion) ......\n"
[[ $is_test_mode -gt 0 ]] && display_options 3
[[ $is_test_mode -gt 0 ]] && message_notification "Configuration \n'$1'\nloaded!.      >$cmdNr<\n" 1 &  
}

# Reading configuration file
read_configuration() {
    script_[config]=$(check_name_is_set $config_stdname $1)                   
    
    [[ $is_test_mode -gt 0 ]] && message_notification "Reading configuration file \n\n${script_[config]}." 1

    # Call function to extract values
    extract_config_values config_elements

    # Replace placeholders from config
    config_elements[menue_strg]=$(replace_placeholder_strg "${config_elements[menue_strg]}" "\$version" "${config_elements[version]}")
    config_elements[menue_strg]=$(replace_placeholder_strg "${config_elements[menue_strg]}" "\$verstxt" "${config_elements[version_strg]}")

    # Ensure the editor-prog is set, defaulting to "gedit" if not provided & checking existence
    [[ -z "${config_elements[editor_prog]}" ]] && config_elements[editor_prog]="${config_elements[editor_prog]:-gedit}"
    check_prog "${config_elements[editor_prog]}"
    check_prog "${config_elements[prog_strg]}"

    read_alloptions ${script_[config]}

    done_configuration ${script_[config]}
    
    echo ${script_[config]}
}

return

# exex test
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
is_test_mode=1

read_configuration "/home/stefan/perl/Bakki-the-stickv1.2beta/config_2408.xml"

#read_alloptions

#done_configuration

exit 0


### junk

tr '\n' ' ' # the easiest?