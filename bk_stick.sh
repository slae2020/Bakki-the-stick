#!/bin/bash
shopt -s extglob
	 
## if $1 leer then ="config.xml" einbauen
echo -e "Starte..........\n" # Testoption

echo $1

[[ -n "$1" ]] && c="$1" || c="config.xml"
echo $c"<"

################# config einlesen
version=$(xml_grep 'version' config.xml --text_only) && verstxt=$(xml_grep 'verstxt' config.xml --text_only)
scriptort=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

title=$(xml_grep 'title' $c --text_only)
text=$(xml_grep 'text' config.xml --text_only) && text=${text/\$version/$version} && text=${text/\$verstxt/$verstxt}   #gefällt mir nicht Name getname ??
config=$(xml_grep 'config' config.xml --text_only)

homeVerz=$(xml_grep 'homeVerz' config.xml --text_only)
stickort=$(xml_grep 'stickort' config.xml --text_only)
StdVerz=$(xml_grep 'StdVerz' config.xml --text_only)
RemoteOrt=$(xml_grep 'RemoteOrt' config.xml --text_only)

## Liste der möglichen Vergleiche (Ordner)
	optName=("")   							#0
	optName+=("kw" "KW" "KW")    	#1-3
	optName+=("KW"   "KW" "kw") 		#4-6
	optName+=("KIMocloud" "dokumente" "kw") 		#7-9
	optName+=("kw"  "rsync_push" "kw") 				#10-12

optName+=($(xml_grep 'name' config.xml --text_only))				#new

	dir1=("" "" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "")
dir1+=($(xml_grep 'dir1' config.xml --text_only))				#new

	dir2=("0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "")
dir2+=($(xml_grep 'dir2' config.xml --text_only))				#new

##
for ((k = 0 ; k < ${#dir2[@]} ; k++)); do 	# standard-Verezeichnis einsetzen oder korrigieren (~ zu /home/stefan/) 
	[[ ${dir1[k]} =~ [~|\$] ]] &&
		dir1[k]=$(echo ${dir1[k]} | sed "s|~|${homeVerz}|;s|\$homeVerz|${homeVerz}|"  \
								  |	sed "s|\$stickort|$stickort|" \
								  |	sed "s|\$StdVerz|$StdVerz|" \
								  |	sed "s|\$RemoteOrt|$RemoteOrt|" \
																						)
	[[ ${dir2[k]} =~ [~|\$] ]] &&																						
		dir2[k]=$(echo ${dir2[k]} | sed "s|~|${homeVerz}|;s|\$homeVerz|${homeVerz}|"  \
								  |	sed "s|\$stickort|$stickort|" \
								  |	sed "s|\$StdVerz|$StdVerz|" \
								  |	sed "s|\$RemoteOrt|$RemoteOrt|" \
																						) 
	done
echo -e "eingelsen!\n" # Testoption

################# Start

### 
ZeigeOptionen () { #fct alle Optionen zur Auswahl anzeigen/ Testoption

	#echo ${#options[*]}
	#for ((k = 0 ; k < ${#options[@]} ; k++)); do 
		#echo $k"-->"${options[k]}

	#echo -e ${#optName[*]}

	#for ((k = 0 ; k < ${#optName[@]} ; k++)); do 
		#echo $k"-->"${optName[k]}
	#done
	#for ((k = 0 ; k < ${#dir1[@]} ; k++)); do 
		#echo $k"-->"${dir1[k]}
	#done
echo "2."
	for ((k = 0 ; k < ${#dir2[@]} ; k++)); do 
		echo $k"-->"${dir2[k]}

	done

	echo .
	echo $auswahl
	#echo ${optName[8]}
	echo .	
	
#	echo $(xml_grep 'version' config.xml --text_only)


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
#echo $lw
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

###
stringContain() { #fct mit [-i]-option für case UNsensitiv!
	if [[ $1 == -i ]]; then
        case ${3,,} in
            *${2,,}*) return 0;;
            *) return 1;;
        esac
    else
        case $2 in
            *$1*) return 0;;
            *) return 1;;
        esac
    fi	
}	


######## Hauptfenster ########

ZeigeOptionen # Testoption

while [ ! "$auswahl" ]; do       # Wiederanzeige bis Auswahl
	auswahl=`zenity --height "350" --width "450" \
	--title "$title" --text "$text" \
	--list --column="Optionen"	${optName[*]} $config \
	` 	
	###### gewaehlt -> abgang ######
	if  [ $? != 0 ]; then
		exit 1
	fi
	[ $? -ne 0 ] && exit 2 # Abbruch
done


###
for i in "${!optName[@]}"; do
			if [[ "${optName[$i]}" = "$auswahl" ]]; then
#echo "${i}"; 
			index=$i
			fi
		done
#echo "+++ "$index" +++"

#### Aufruf ####
case $auswahl in

	#${options[0etc]})  # für alle slae01 bis SLAE99 ; nur ALLEGROSS oder alleklein
	#+([slae|SLAE])??) 
		#eingesteckt $auswahl
		#meld ~/slae_kim "$stickort/"$auswahl"/slaekim"
		#;;
	${options[1]}|${options[12]})  #	usrIserv)  #usr
	    verbunden "/mnt/iserv_laettig/"     # erst mounten!
		meld  /home/stefan/slae_kim/usr "/mnt/iserv_laettig/Files/usr"
		;;	
	${options[2]})  #	untIserv)  #unt
	    verbunden "/mnt/iserv_laettig/"     # erst mounten!
		meld  /home/stefan/slae_unt "/mnt/iserv_laettig/Files/unt"
		;;	
	${options[3]})  #	ausdruck)  #drucken
	    verbunden "/mnt/iserv_laettig/"     # erst mounten!
		meld  /home/stefan/slae_kim/ausdruck "/mnt/iserv_laettig/Files/ausdruck"
		;;	
	${options[4]})  #	ABFUNT) #ab nach unt shuffeln
		meld  /home/stefan/slae_kim/abf "/home/stefan/slae_unt"		
		;;
	#${options[5]})  #	SLAE03
	#${options[6]})  #	KeePass)  #6
	
	${optName[$index]})  #	new aus config

#echo .
#echo "AAAA"
#echo $auswahl"<->"${optName[$index]}
#echo ">"${dir1[$index]}"<"
#echo ">"${dir2[$index]}"<"

		stringContain "/media/" "${dir2[$index]}" && eingesteckt "${dir2[$index]}" "${optName[$index]}" #in eine verbunden fct?

		stringContain "/mnt/" "${dir1[$index]}" && verbunden "${dir1[$index]}"
		stringContain "/mnt/" "${dir2[$index]}" && verbunden "${dir2[$index]}"  #in eine verbunden fct?
		###
		[[ ${dir1[$index]} =~ [\/] ]] &&
		meld ${dir1[$index]} ${dir2[$index]} || echo "FEhler 66"
		;;
#??? 		
	#${optName[0etc]})  # für alle slae01 bis SLAE99 ; nur ALLEGROSS oder alleklein
	
	#+([slae|SLAE])??) 
		#eingesteckt $auswahl
		#meld ~/slae_kim "$stickort/"$auswahl"/slaekim"
		#;;
		
	#${optName[1]}|${optName[12]})  #	usrIserv)  #usr
	    #verbunden "/mnt/iserv_laettig/"     # erst mounten!
##obsol		meld  /home/stefan/slae_kim/usr "/mnt/iserv_laettig/Files/usr"
#		;;	
	#${optName[2]})  #	untIserv)  #unt
	    #verbunden "/mnt/iserv_laettig/"     # erst mounten!
		#meld  /home/stefan/slae_unt "/mnt/iserv_laettig/Files/unt"
		#;;	
	#${optName[3]})  #	ausdruck)  #drucken
	    #verbunden "/mnt/iserv_laettig/"     # erst mounten!
		#meld  /home/stefan/slae_kim/ausdruck "/mnt/iserv_laettig/Files/ausdruck"
		#;;	
	#${optName[4]})  #	ABFUNT) #ab nach unt shuffeln
		#meld  /home/stefan/slae_kim/abf "/home/stefan/slae_unt"		
		#;;
	#${optName[5]})  #	SLAE03
#osol	

	${optName[6]})  #	KeePass)  #6
	echo "Fehler! kw!"

		verbunden "/mnt/iserv_laettig/"     # erst mounten!
		meld  ~/.door3 "/mnt/iserv_laettig/Files/kp/myt"
		;;		
	${optName[7]})  #	KIMocloud)
	echo "Fehler! kw!"

## für slaekim?!?	über nextcloud-app...
		;;		
	${optName[8]})  #	dokumente)
	echo "Fehler! kw!"
## tbd erst abfragen ob Verbindung afp (oder mnt) ?
	# 	meld /home/stefan/dokumente  "afp://stefan@willem.local/francois3/dokumente"
	    ;;		
	${optName[9]})   #   ??#1
	echo "Fehler! kw!"
		echo "Heureka!"
		;;	
	#${optName[10]})  #	meld)
		#echo "Fehler! kw!"
		##meld
		#;;
	${optName[11]})  #	rsync_push)	
	echo "Fehler! kw!"
		#~/perl/rsync_push.sh
		echo "tbd"
		;;

	$config)
		geany "$scriptort${0:1}"
		;;
	*) # caseelse
echo "Fehler 77! (caseelse)"	
		;;
esac

exit 0

