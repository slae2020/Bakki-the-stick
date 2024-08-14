#!/usr/bin/env bash

declare messenger_top_text="Meldung"
declare mwidth=250

# Error-window & exit with error number; default-value 1 when missing; wait for response except for err==0
message_exit() {
    local txt=$1
    local err=$2
    err="${err:-1}"
    txt=$(echo "$txt" | sed "s|: |:\n|")
    
    if [[ $err -gt 0 ]]; then
        zenity --error --width $mwidth --title "$messenger_top_text" --text="$txt ($err)"
    fi
    exit $err
    #return $err
}

# Notification-window with timout after $2 sec or click
message_notification() {
    local txt=$1
    local -i time=$2
    
    if [[ $time -gt 0 ]]; then
        zenity --notification  --window-icon="info" --text="$messenger_top_text\n""$txt" --timeout=$time &
    fi
}

# Ask for conformation to continue (==0) else exit with error $2
ask_to_continue() {
	local txt=$1
	local err=$2
	err="${err:-1}"
	txt=$(echo "$txt" | sed "s|: |:\n|")
	
	zenity --question --width $mwidth --title "$messenger_top_text" --text="$txt ($err)"
    if [ $? -ne 0 ]; then
		exit $err
    fi
    return 0
}

return

#message_notification "swas anders: jdjdu" 1

#message_exit "was: ss" 1

ask_to_continue "weiter?" 21



exit 0
