#!/usr/bin/env bash

source messenge.sh

declare dir_usb="media/"
declare dir_mnt="mnt/"

# Function to check if a path is readable
check_path() {
    local path=$1
    local name=$2

    if [[ $path =~ $dir_usb ]]; then
        check_usb "$path" "$name"
    fi
    if [[ $path =~ $dir_mnt ]]; then
        check_mount "$path"
    fi
    if [[ !  -r "$path" ]]; then
        path="${path:-   }"
        message_exit "Config-Error: Path \n'$path'\n is not readable." 23
    fi
}

# Function to check if a USB stick is present
check_usb() {
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
check_path_is_set() {
    # Parameters:
    #   $1 - local_std_path: The standard path to check
    #   $2 - local_cust_path: The custom path to use if provided

    local local_std_path=$1
    local local_cust_path=${2:-$local_std_path}  # Use local_cust_path if provided, otherwise use standard_path
    local local_dir=$(cd -- "$(dirname -- "$(readlink -f "$0")")" &> /dev/null && pwd)"/"

    # Exit if local_std_path is empty
    if [[ -z "$local_std_path" ]]; then
        echo "Error: Standard path is not set." >&2
        exit 1
    fi

    # Modify local_cust_path if its directory is the current directory
    if [[ "$(dirname "$local_cust_path")" == "." ]]; then
        local_cust_path="$local_dir$local_cust_path"
    fi

    check_path "$local_cust_path"
    #return:
    echo "$local_cust_path"
}

# Function to check availibility of a program
check_prog() {
    local prog_name=$1

    if [[ ! -x "$(command -v $prog_name)" ]]; then
        message_exit "Config-Error: program '$prog_name' not found." 24
    fi
}

return

#check_usb "/media/slaekim" "SLAE77"

check_mount "/mnt/iserv_laettig/Filesö"
