#!/usr/bin/env bash

#source messenge.sh

# Function to check if a path is readable
check_path() {
    local path=$1
    local name=$2

    if [[ $path =~ "/media/" ]]; then
        check_stick "$path" "$name"
    fi
    if [[ $path =~ "mnt/" ]]; then
        check_mount "$path"
    fi
    if [[ !  -r "$path" ]]; then
        path="${path:-   }"
        message_exit "Config-Error: Path \n'$path'\n is not readable." 23
    fi
}

# Function to check if a USB stick is present
check_stick() {
    local stick_path=$1
    local stick_name=$2
    while true; do
        if ls -A "$stick_path" >/dev/null 2>&1; then
            break
        else
            ask_to_continue "'$stick_name' is missing: [  '$stick_path' not found  ]\n\nDo you want to try again?" 21           
        fi
    done
}

# Function to check if a network drive is mounted, and attempt to mount it if not
check_mount() {
    local mounted_path=$1
    local test_subdir=$mounted_path"/."

    # Check if the mount-directory is accessible
    if [[ ! -r "$test_subdir" ]]; then
        # Attempt to mount the directory
        mnt_resp=$(/home/stefan/prog/bakki/mounti/mounter.sh "$mounted_path" )
        if [[ ! "$mnt_resp" == 0 ]]; then
            message_exit "Error: $mnt_resp" 22
        fi
    fi
}

# Validate and modify a path based on certain conditions
check_name_is_set() {
    # Parameters:
    #   $1 - standard_path: The standard path to check
    #   $2 - custom_path: The custom path to use if provided

    local standard_path=$1
    local custom_path=${2:-$standard_path}  # Use custom_path if provided, otherwise use standard_path

    # Exit if standard_path is empty
    if [[ -z "$standard_path" ]]; then
        echo "Error: Standard path is not set." >&2
        exit 1
    fi

    # Modify custom_path if its directory is the current directory
    if [[ "$(dirname "$custom_path")" == "." ]]; then
        custom_path="${script_[dir]}$custom_path"      # ???? script[dir] raus???
    fi

    check_path "$custom_path"

    echo "$custom_path"
}

# Function to check availibility of a program
check_prog() {
    local prog_name=$1

    if [[ ! -x "$(command -v $prog_name)" ]]; then
        message_exit "Config-Error: program '$prog_name' not found." 24
    fi
}

#check_stick "/media/slaekim" "SLAE77" 
