#!/bin/bash
shopt -s extglob

#eintraege="SLAE01 usrIserv untIserv ausdruck ABFUNT SLAE03 KeePass KIMocloud meld hier3Test"
#################
#Liste der möglichen Vergleiche (Ordner)
options=("SLAE01")   							#0
options+=("usrIserv" "untIserv" "ausdruck")    	#1-3
options+=("ABFUNT"   "SLAE03" "KeePass") 		#4-6
options+=("KIMocloud" "dokumente" "??#1") 		#7-9
options+=("meld"  "rsync_push") 		#10-12

		 
#nur hier eintraeg editieren, dann automatisch unten? eintraege[12] ?
version="1.00" # slae 2024-07 Start mit git

#################
title="Starter BK"
text="Meld-Vergleich auswählen"
config="Einstellungen"
stickort="/media/stefan"

#################
echo -e "Starte..........\n"

#echo ${options[9]}

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
#--list --column="Eintraege"	$eintraege $config \

while [ ! "$auswahl" ] # Wiederanzeige bis Auswahl
do
	auswahl=`zenity --height "350" --width "450" \
	--title "$title" --text "$text" \
	--list --column="Eintraege"	${options[*]} $config \
	` 	
	###### gewaehlt -> abgang ######
	if  [ $? != 0 ]; then
		exit 1
	fi
	[ $? -ne 0 ] && exit 2 # Abbruch
done

#echo ${options[*]}
for ((k = 0 ; k < 10 ; k++)); do 
	echo $k"-->"${options[k]}
done
echo .
echo $auswahl
#echo ${options[8]}
echo .

#### Aufruf ####
case $auswahl in
	#${options[0etc]})  # für alle slae01 bis SLAE99 ; nur ALLEGROSS oder alleklein
	+([slae|SLAE])??) 
		eingesteckt $auswahl
		meld ~/slae_kim "$stickort/"$auswahl"/slaekim"
		;;
	${options[1]})  #	usrIserv)  #usr
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
		geany ~/perl/bk_stick.sh
		;;
	*) # caseelse
	
		;;
esac

exit 0

