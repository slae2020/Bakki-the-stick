#!/bin/bash
shopt -s extglob

################# Liste der möglichen Vergleiche (Ordner)
options=("SLAE01")   							#0
options+=("usrIserv" "untIserv" "ausdruck")    	#1-3
options+=("ABFUNT"   "SLAE03" "kw") 		#4-6
options+=("KIMocloud" "dokumente" "kw") 		#7-9
options+=("kw"  "rsync_push" "kw") 				#10-12

options+=($(xml_grep 'name' config.xml --text_only))				#new
dir1=("0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12")
dir1+=($(xml_grep 'dir1' config.xml --text_only))				#new
dir2=("0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12")
dir2+=($(xml_grep 'dir2' config.xml --text_only))				#new
### standard-Verezeichnis einsetzen oder korrigieren (~ zu /home/stefan/) 
 
################# 
version=$(xml_grep 'version' config.xml --text_only)
ee=$(xml_grep 'versionstxt' config.xml --text_only)

title=$(xml_grep 'title' config.xml --text_only) 
text=$(xml_grep 'text' config.xml --text_only) && text=${text/\$version/$version} && text=${text/\$versionstxt/$ee}   #gefällt mir nicht Name getname ??

config=$(xml_grep 'config' config.xml --text_only)

stickort=$(xml_grep 'stickort' config.xml --text_only)
scriptort=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

################# Start

### fct alle Optionen zur Auswahl anzeigen/ Testoption
ZeigeOptionen () {
	#echo ${#options[*]}
#	for ((k = 0 ; k < ${#options[@]} ; k++)); do 
#		echo $k"-->"${options[k]}
#	done
	for ((k = 0 ; k < ${#dir1[@]} ; k++)); do 
		echo $k"-->"${dir1[k]}
	done
	echo . 
	echo $auswahl
	#echo ${options[8]}
	echo .	
	
#	echo $(xml_grep 'name' config.xml --text_only)

#	echo $scriptort
#	echo "$0"         #scriptname
}
###

### fct  Stick drin ?
eingesteckt ( ) {
		ls -a "$stickort/"$1"/slaekim/" >/dev/null 2>&1
		while [ $? != 0 ] # Fenster wiederholen bis gefunden oder Abbruch
		do
			zenity --question --title="$title" --width="350" --text="Stick '$1' fehlt! \nNoch einen Versuch ?" 			
			if  [ $? != 0 ]; then
				exit 1
			fi
			[ $? -ne 0 ] && exit 2 # Abbruch
			ls -a "$stickort/"$1"/slaekim/" >/dev/null 2>&1
		done
}
###

### fct Netzlaufwerk verbunden ?
verbunden ( ) {
		lw=$1"Files" #Beliebiges Unterverzeichnis, das immer da ist, zum testen.
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

######## Hauptfenster ########
echo -e "Starte..........\n" # Testoption
ZeigeOptionen # Testoption

while [ ! "$auswahl" ]; do       # Wiederanzeige bis Auswahl
	auswahl=`zenity --height "350" --width "450" \
	--title "$title" --text "$text" \
	--list --column="Optionen"	${options[*]} $config \
	` 	
	###### gewaehlt -> abgang ######
	if  [ $? != 0 ]; then
		exit 1
	fi
	[ $? -ne 0 ] && exit 2 # Abbruch
done


###
for i in "${!options[@]}"; do
			if [[ "${options[$i]}" = "$auswahl" ]]; then
			#echo "${i}"; 
			index=$i
			fi
		done
#echo "+++ "$index" +++"



#### Aufruf ####
case $auswahl in
	#${options[0etc]})  # für alle slae01 bis SLAE99 ; nur ALLEGROSS oder alleklein
	+([slae|SLAE])??) 
		eingesteckt $auswahl
		meld ~/slae_kim "$stickort/"$auswahl"/slaekim"
		;;
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
	${options[6]})  #	KeePass)  #6
		verbunden "/mnt/iserv_laettig/"     # erst mounten!
		meld  ~/.door3 "/mnt/iserv_laettig/Files/kp/myt"
		;;		
	${options[7]})  #	KIMocloud)

## für slaekim?!?	über nextcloud-app...
		;;		
	${options[8]})  #	dokumente)
## tbd erst abfragen ob Verbindung afp (oder mnt) ?
	# 	meld /home/stefan/dokumente  "afp://stefan@willem.local/francois3/dokumente"
	    ;;		
	${options[9]})   #   ??#1
#obsol		echo "Heureka!"
		;;	
	${options[10]})  #	meld)
#obsol		meld
		;;
	${options[11]})  #	rsync_push)	
		#~/perl/rsync_push.sh
		echo "tbd"
		;;

#ab 13 new aus config
	${options[$index]})  #	
		echo .
		echo "AAAA"
		echo $auswahl"<->"${options[$index]}
		echo ">"${dir1[$index]}"<"
		echo ">"${dir2[$index]}"<"
#eingesteckt??
# verbunden ???		if mnt in...
		
		meld ${dir1[$index]} ${dir2[$index]}
		;;
	$config)
		geany "$scriptort${0:1}"
		;;
	*) # caseelse
echo .
echo "Fehler! Was tun?"	
echo $ausdruck
echo .
		;;
esac

exit 0

