#!/bin/bash
shopt -s extglob

#################
### old eintraege="KIM kigapub_kiga kigafin rot_kiga alle_drei rsync_push meld"
### "0.6" # slae 2018-03-03
### "0.7" # slae 2018-11-27
### "0.8" # slae 2019-05-24
### "0.81" # slae 2020-11-14
### "0.82" # slae 2021-02-07
### "0.9" # slae 2022-02-10 mit iserv & sudo-mount
### "0.91" # slae 2023-10 iserv.ausdruck & abf<->unt ergaenzt
### "0.92" # slae 2024-03 unt verschoben nach slae_unt


eintraege="SLAE01 usrIserv untIserv ausdruck ABFUNT SLAE03 KeePass KIMocloud meld"
version="1.00" # slae 2024-07 Start mit git

# nächstes ocloud ?  Auswahl für verschiedene Ordner auf iserv?

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

## old stuff

alle_drei)
		## Stick drin ?
		ls -a /media/ROT_8GB/* >/dev/null 2>&1
		while [ $? != 0 ] # Fenster wiederholen bis gefunden oder Abbruch
		do
			zenity --question --title="$title" --width="350" --text="Stick fehlt! \nNoch einen Versuch ?" \
			--window-icon=$HOME/.icons/elementary/status/48/important.svg
			if  [ $? != 0 ]; then
				exit 1
			fi
			[ $? -ne 0 ] && exit 2 # Abbruch
			ls -a /media/ROT_8GB/* >/dev/null 2>&1
		done
		meld /media/ROT_8GB/kiga /home/stefan/kigapub ~/kiga
		;;

#gemountet ?
ans="`truecrypt -t -l | sed -e s/" \/[^home]".*$//`"
if [ "$ans" != "" ]
then 
	zenity --question --title="$title" --width="350" --text="   Gefundenes Volume:\n$ans\n\n   Ist das richtig ?"
	if [ $? != 0 ]
	then
	truecrypt -d
	truecrypt --auto-mount=favorites --load-preferences
	fi
else
	truecrypt --auto-mount=favorites --load-preferences
fi

#meld
#meld /media/ROT_8GB/kiga /home/stefan/kiga /home/stefan/clark/kiga
#meld ~/kigapub ~/kiga
