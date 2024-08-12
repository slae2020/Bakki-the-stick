#!/usr/bin/env bash

source messenge.sh

# Function to check if a USB stick is present
check_stick() {
    local stick_path=$1
    local stick_name=$2
    while true; do
        if ls -A "$stick_path" >/dev/null 2>&1; then
            break
        else
            zenity --question --title ${script_[name]} --width="350" --text="'$stick_name' is missing!\n[  '$stick_path' not found  ]\nDo you want to try again? (21)"
            if [ $? -ne 0 ]; then
                exit 21
            fi
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
            exit
        fi
    fi
}

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
        exit
    fi
}
# Function to check availibility of a program
check_prog() {
    local prog_name=$1

    if [[ ! -x "$(command -v $prog_name)" ]]; then
        message_exit "Config-Error: program '$prog_name' not found." 24
        exit
    fi
}
