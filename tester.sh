#!/usr/bin/env bash

#source declarations.sh

# Display options for selection
display_options () {
	local select=$1
    echo .
    echo "Display var for debugging info:"

	case $select in
		1) echo $cmdNr ;;
		2)
		for i in "${!script_[@]}"; do
			echo -n "$i -->"
			echo ${script_[$i]}
		done 
		;;
		3)
		echo .
		echo "Extracted IDs: ${id[@]}"
		echo "Extracted Names: ${sync_name[@]}"
		echo "Extracted Param: ${sync_param[@]}"
		echo "Extracted dir 1: ${sync_dir1[@]}"
		echo "Extracted dir 2: ${sync_dir2[@]}"
		;;
		4)
		for i in "${!config_elements[@]}"; do
			echo -n "$i -->"
			echo ${config_elements[$i]}
		done
		;;
		5)
		echo "Extracted IDs: ${id[@]}"
		echo "Extracted NamesO: ${sync_name[@]}"
		echo "Extracted NamesN: ${option[name]}"
		for i in "${!option[@]}"; do
			echo -n "$i -->"
			echo ${option[$i]}
		done 
		

		;;
	esac
	echo .
	echo "Wahl: $selection""<- cmdNr->"$cmdNr"<"
}
