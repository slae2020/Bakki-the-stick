#!/bin/bash
shopt -s extglob

eintraege="SLAE01 usrIserv untIserv ausdruck ABFUNT SLAE03 KeePass KIMocloud meld"
version="1.00" # slae 2024-07 Start mit git

#################
title="Starter BK"
text="Meld-Vergleich auswählen"
config="Einstellungen"
stickort="/media/stefan"

#################
# echo -e "Starte..........\n"

### function  Stick drin ?
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

### function Netzlaufwerk verbunden ?
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
while [ ! "$auswahl" ] # Wiederanzeige bis Auswahl
do
	auswahl=`zenity --height "250" --width "450" \
	--title "$title" --text "$text" \
	--list --column="Eintraege"	$eintraege $config \
	` 	
	###### gewaehlt -> abgang ######
	if  [ $? != 0 ]; then
		exit 1
	fi
	[ $? -ne 0 ] && exit 2 # Abbruch
done

#echo Klll
#echo $auswahl
#echo .

#### Aufruf ####
case $auswahl in
	+([slae|SLAE])??) #für alle slae01 bsi SLAE99
		eingesteckt $auswahl
		meld ~/slae_kim "$stickort/"$auswahl"/slaekim"
		;;
	KeePass)
		verbunden "/mnt/iserv_laettig/"     # erst mounten!
		meld  ~/.door3 "/mnt/iserv_laettig/Files/kp/myt"
		;;
	KIMocloud)
## für slaekim?!?	über nextcloud-app...
		;;
	usrIserv)  #usr
	    verbunden "/mnt/iserv_laettig/"     # erst mounten!
		meld  /home/stefan/slae_kim/usr "/mnt/iserv_laettig/Files/usr"
		;;	
	untIserv)  #unt
	    verbunden "/mnt/iserv_laettig/"     # erst mounten!
		meld  /home/stefan/slae_unt "/mnt/iserv_laettig/Files/unt"
		;;	
	ausdruck)  #drucken
	    verbunden "/mnt/iserv_laettig/"     # erst mounten!
		meld  /home/stefan/slae_kim/ausdruck "/mnt/iserv_laettig/Files/ausdruck"
		;;	
	ABFUNT) #ab nach unt shuffeln
		meld  /home/stefan/slae_kim/abf "/home/stefan/slae_unt"		
		;;
	rsync_push)	
		~/perl/rsync_push.sh
		;;
	meld)
		meld
		;;
	$config)
		geany ~/perl/bk_stick.sh
		;;
	*) # caseelse
	
		;;
esac

exit 0

