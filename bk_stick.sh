#!/bin/bash
shopt -s extglob

################# Liste der möglichen Vergleiche (Ordner)
options=("SLAE01")   							#0
options+=("usrIserv" "untIserv" "ausdruck")    	#1-3
options+=("ABFUNT"   "SLAE03" "KeePass") 		#4-6
options+=("KIMocloud" "dokumente" "??#1") 		#7-9
options+=("meld"  "rsync_push" "~/slae_kim/usr") 				#10-12
	 
version="1.00" # slae 2024-07 Start mit git
version=$(xml_grep 'version' config.xml --text_only)
ee=$(xml_grep 'versionstxt' config.xml --text_only)

################# 
title=$(xml_grep 'title' config.xml --text_only)
text=$(xml_grep 'text' config.xml --text_only)
config=$(xml_grep 'config' config.xml --text_only)
stickort=$(xml_grep 'stickort' config.xml --text_only)
scriptort=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

################# Start

### fct alle Optionen zur Auswahl anzeigen/ Testoption
ZeigeOptionen () {
	#echo ${#options[*]}
	for ((k = 0 ; k < ${#options[@]} ; k++)); do 
		echo $k"-->"${options[k]}
	done
	echo .
	echo $auswahl
	#echo ${options[8]}
	echo .	
	
	echo $(xml_grep 'version' config.xml --text_only)

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
		echo "Heureka!"
		;;	
	${options[10]})  #	meld)
		meld
		;;
	${options[11]})  #	rsync_push)	
		#~/perl/rsync_push.sh
		echo "tbd"
		;;

	$config)
		geany "$scriptort${0:1}"
		;;
	*) # caseelse
	
		;;
esac

exit 0

