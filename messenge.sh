#!/usr/bin/env bash

# For returning string while aborting message
declare is_cancel="#x0020"

declare messenger_top_text="Message"
declare messenger_sub_text="Please choose"
declare messenger_column1_text="Options"

declare dialog_height=350
declare dialog_width=250

# Check if variable is an array [$1: variable name]
function is_array() {
    if [[ "$(declare -p "$1" 2>/dev/null)" == "declare -a"* ]]; then
        echo 0
    else
        echo 1
    fi
}

# Check if variable is a dict [$1: variable name]
function is_dict() {
    if [[ "$(declare -p "$1" 2>/dev/null)" == "declare -A"* ]]; then
        echo 0
    else
        echo 1
    fi
}

# Error-window & exit with error number; default-value 1 when missing; wait for response except for err==0
message_exit() {
    local txt=$1
    local err=$2
    err="${err:-1}"
    txt=$(echo "$txt" | sed "s|: |:\n|")

    if [[ $err -gt 0 ]]; then
        zenity --error --width $dialog_width --title "$messenger_top_text" --text="$txt ($err)"
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

    zenity --question --width $dialog_width --title "$messenger_top_text" --text="$txt ($err)"
    if [ $? -ne 0 ]; then
        exit $err
    fi
    return 0
}

# Ask for selection out of list; first 3 strings for titles etc; $is_cancel if no choose
ask_to_choose() {  
    local -n main_options
    local -a additional_options
    local -a dialog_texts

	#Loop for reading $@ (one! array for options-array)
	local i=0; local j=1
    while [[ -n $@ ]]; do
        if [[ $(is_array $1) -eq 0 ]]; then
            main_options=$1
        else
            if [[ $j -lt 4 ]]; then
                dialog_texts[$j]=$1
            else
                additional_options[$j]=$1
            fi
            j=$((j + 1))
        fi

    i=$((i + 1))
    shift
    done

	# Merge & Defaults if not found
    main_options=("${main_options[@]}" "${additional_options[@]}")
    dialog_texts[1]=${dialog_texts[1]:-$messenger_top_text}
    dialog_texts[2]=${dialog_texts[2]:-$messenger_sub_text}
    dialog_texts[3]=${dialog_texts[3]:-$messenger_column1_text}

    dialog_height=350 # ??? Uebergabe?
    dialog_width=450

    answer=$(zenity --list --height $dialog_height --width $dialog_width \
             --title "${dialog_texts[1]}" --text="${dialog_texts[2]}" \
             --column="${dialog_texts[3]}" "${main_options[@]}" )
    if [ $? -ne 0 ]; then
        answer=$is_cancel
    fi
    echo $answer
}

return

#message_notification "swas anders: jdjdu" 1

#message_exit "was: ss" 1

#ask_to_continue "weiter?" 21

declare -a testi
testi[0]="0 "
testi[1]="10"
testi[2]=" 10w"
testi[3]="22   "
testi[5]=" Versuch Luecke  "
testi[7]="osz"$is_cancel"iserv"
a=1
b="ww, die absoluet Extraportion"

echo "99"
echo $(is_array a)
echo $(is_array b)
echo $(is_array testi)

for pos in ${!testi[@]}; do
 echo $pos"->"${testi[$pos]}
done

declare -p testi

echo .
#echo ">"$(ask_to_choose "MyHuhu" testi "MyVersion" "MyOptionen"  "$a" "$b")"<"
echo ">"$(ask_to_choose "" "" "" testi )"<"

#ask_to_continue "weiter?" 21

exit 0
