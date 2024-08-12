#!/usr/bin/env bash

# Error-window & exit with error number; default-value 1 when missing; wait for response except for err==0
message_exit() {
    local txt=$1
    local err=$2
    err="${err:-1}"
    txt=$(echo "$txt" | sed "s|: |:\n|")
    if [[ $err -gt 0 ]]; then
        zenity --error --width "250" --title ${script_[name]} --text="$txt ($err)"
    fi
    return $err
}
