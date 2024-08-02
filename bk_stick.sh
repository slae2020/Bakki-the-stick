#!/bin/bash
shopt -s extglob

declare -i cmdNr

echo -e "Starte..........\n" # Testoption
echo "$pwd"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo $SCRIPT_DIR

echo "The script you are running has:"
echo "basename: [$(basename "$0")]"
echo "dirname : [$(dirname "$0")]"
echo "pwd     : [$(pwd)]"




################ args einlesen
while getopts ':c:e:n:h' OPTION;  do # -c "$cfile" -e geany -n automatisch# -h help
	case "$OPTION" in
		c)
		cfile=${OPTARG}
		;;
		e)
 		confProg=${OPTARG}
		;;
		n)
		cmdNr=${OPTARG} || unset cmdNr # wenn keine Zahl dann leeren
		;;
		?|h)
		echo "Usage: $(basename $0) [-c Konfiguration.xml] [-e Editor] [-h]"
		exit 1
		;;
	esac
done

################# config einlesen
[[ -z "$cfile" ]] && cfile="config.xml"
version=$(xml_grep 'version' "$cfile" --text_only) && verstxt=$(xml_grep 'verstxt' "$cfile" --text_only)
scriptort=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

title=$(xml_grep 'title' $cfile --text_only)
text=$(xml_grep 'text' "$cfile" --text_only) && text=${text/\$version/$version} && text=${text/\$verstxt/$verstxt}
config=$(xml_grep 'config' "$cfile" --text_only)
[[ -z "$confProg" ]] && confProg=$(xml_grep 'confProg' "$cfile" --text_only)
meld=$(xml_grep 'meld' "$cfile" --text_only)

homeVerz=$(xml_grep 'homeVerz' "$cfile" --text_only)
stickort=$(xml_grep 'stickort' "$cfile" --text_only)
StdVerz=$(xml_grep 'StdVerz' "$cfile" --text_only)
RemoteOrt=$(xml_grep 'RemoteOrt' "$cfile" --text_only)

## Liste der möglichen Vergleiche (Ordner)
ident+=($(xml_grep 'id' "$cfile" --text_only))
optName+=($(xml_grep 'name' "$cfile" --text_only))
dir1+=($(xml_grep 'dir1' "$cfile" --text_only))
dir2+=($(xml_grep 'dir2' "$cfile" --text_only))

###
for ((k = 0 ; k < ${#dir2[@]} ; k++)); do 	# standard-Verzeichnis einsetzen oder korrigieren (~ zu /home/stefan/)
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
[[ $cmdNr -lt ${#ident[@]} ]]  || unset cmdNr # wenn cmdNr nicht auf Liste loeschen

echo -e "eingelesen! >$cmdNr\n" # Testoption

################# Start

###
ZeigeOptionen () { #fct alle Optionen zur Auswahl anzeigen/ Testoption

#declare -p | grep ident
#declare -p | grep optName

	#echo ${#options[*]}
	#for ((k = 0 ; k < ${#options[@]} ; k++)); do
		#echo $k"-->"${options[k]}

	#echo -e ${#optName[*]}

	#for ((k = 0 ; k < ${#ident[@]} ; k++)); do
		#echo $k"-->"${ident[k]}

	#done
	##for ((k = 0 ; k < ${#optName[@]} ; k++)); do
		##echo $k"-->"${optName[k]}
	##done
	##for ((k = 0 ; k < ${#dir1[@]} ; k++)); do
		##echo $k"-->"${dir1[k]}
	##done
#echo "2."
	#for ((k = 0 ; k < ${#dir2[@]} ; k++)); do
		#echo $k"-->"${dir2[k]}

	#done

	echo .
	echo $auswahl
	#echo ${optName[8]}
	echo .

#	echo $(xml_grep 'version' "$cfile" --text_only)


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
# ZeigeOptionen # Testoption

[[ -n $cmdNr ]] && index=$cmdNr || # falls cmdNr nicht leer Abfrage ueberspringen
while [ ! "$auswahl" ]; do       # Wiederanzeige bis Auswahl
	auswahl=`zenity --height "350" --width "450" \
	--title "$title" --text "$text" \
	--list --column="Optionen"	${optName[*]} $meld $config \
	`
	###### gewaehlt -> abgang ######
	if  [ $? != 0 ]; then
		exit 1
	fi
	[ $? -ne 0 ] && exit 2 # Abbruch
done

###
for i in "${!optName[@]}"; do
	[[ "${optName[$i]}" = "$auswahl" ]] && index=$i
	done
[[ -z $index ]] || auswahl=${optName[$index]} # Absicherung 
#echo $auswahl"+++ "$index" +++"${ident[$index]}"##"${dir2[$index]} #Testoption

#### Aufruf ####
case $auswahl in
	$meld)     	# meld pur)
		meld || echo "Fehler 87"
		;;
	$config)  	# script ändern)
		$confProg "$scriptort${0:1}" || echo "Fehler 88"
		;;
	${optName[$index]})
		grep -q "/media/" <<<"${dir1[$index]}" && eingesteckt "${dir1[$index]}" "${optName[$index]}"
		grep -q "/media/" <<<"${dir2[$index]}" && eingesteckt "${dir2[$index]}" "${optName[$index]}"
		grep -q "/mnt/"   <<<"${dir1[$index]}" && verbunden "${dir1[$index]}"
		grep -q "/mnt/"   <<<"${dir2[$index]}" && verbunden "${dir2[$index]}"
		###
		[[ ${dir1[$index]} =~ [\/] || ${dir2[$index]} =~ [\/] ]] &&
		meld ${dir1[$index]} ${dir2[$index]} >/dev/null 2>&1  || echo "Falsche(r) Ordner für $optName[$index] '"${dir1[$index]}"'||'"${dir2[$index]}"' / (Fehler 66)" 
		;;
	*) 			# caseelse
		echo "Fehler 99 (caseelse)"
		;;
esac

exit 0

## ab hier junk
