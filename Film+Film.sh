#!/usr/bin/env bash

#------------------------------------------------------------------------------#
#
# Mit diesem Skript kann man mehrere Filmteile aneinander reihen.
# Allerdings sollte man darauf achten, dass alle Teile zueinander kompatibel
# sind, sonst kann es beim abspielen zu Problemen kommen.
#
# Mit diesem Skript kann man gewaltigen Ausschuss produzieren, der auf dem
# ersten Blick nicht einmal auffällt!!!
# Damit meine ich, dass es (wenn man bestimmte Fehler macht) völlig zufällig
# sein kann, ob der Film nachher auf anderen Geräten abgespielt werden kann.
# Meistens wird er mit VLC und MPlayer gut laufen aber im Browser, auf dem Handy
# oder der MediaBox sowie anderen Geräten u.U. nicht komplett oder
# überhaupt nicht!
#
# Die sicherste Methode, mit diesem Skript gute Ergebnisse zu erhalten, ist
# z.B. diese:
# verwenden Sie zum konvertieren der einzelnen Filmteile, die später mit diesem
# Skript aneinander gereiht werden sollen, das Skript Film2MP4.sh
# (https://github.com/FlatheadV8/Film2MP4)
# Dabei ist unbedingt darauf zu achten, dass Sie für alle Einzelteile jeweils
# genau die gleichen Angaben für diese beiden Parameter verwenden:
#   -soll_xmaly
#   -dar
# zum Beispiel würde man für 3 Teile dieses tun:
#   ~/bin/Film2MP4.sh -soll_xmaly 1920x1080 -dar 16:9 -q 1.avi -z 1.mkv
#   ~/bin/Film2MP4.sh -soll_xmaly 1920x1080 -dar 16:9 -q 2.avi -z 2.mkv
#   ~/bin/Film2MP4.sh -soll_xmaly 1920x1080 -dar 16:9 -q 3.avi -z 3.mkv
#   ~/bin/Film+Film.sh komplett 1.mkv 2.mkv 3.mkv
#
# Der fertige Film, aus diesem Beispiel, hat am Ende den Namen "komplett.mkv".
# Dieses Skript kann nur MKV-Dateien produzieren.
#
# Es ist auch sinnvoll (wie im Beispiel zu sehen), dass man mit dem MKV-Format
# arbeitet, andernfalls muss dieses Skript den entsprechenden Film-Teil
# vor dem zusammen fühgen nocheinmal ins MKV-Format übersetzen.
#
# Es werden folgende Programme von diesem Skript verwendet:
#  - ffmpeg
#  - mkvmerge (aus dem Paket mkvtoolnix)
#
#------------------------------------------------------------------------------#

#set -x

VERSION="v2017050400"

#set -x
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

LANG=C		# damit AWK richtig rechnet

#==============================================================================#

if [ -z "$1" ] ; then
	echo "${0} Filmfertig [Filmteil1.mp4] [Filmteil2.mp4] [Filmteil3.mp4]"
	exi 1
fi

AUFRUF="${0} $@"

#==============================================================================#
### Programm

PROGRAMM="$(which avconv)"
if [ -z "${PROGRAMM}" ] ; then
        PROGRAMM="$(which ffmpeg)"
fi

if [ -z "${PROGRAMM}" ] ; then
        echo "Weder avconv noch ffmpeg konnten gefunden werden. Abbruch!"
        exit 1
fi

#==============================================================================#
### Es können nur Filmteile im Matroska-Format aneinandergereiht werden.

NAME_NEU="${1}"
shift
FILM_TEILE="${@}"

rm -f ${NAME_NEU}.txt
echo "${AUFRUF}" > ${NAME_NEU}.txt

unset MKV_TEILE

for FILMDATEI in ${FILM_TEILE}
do
	echo "-> ${FILMDATEI}"

	if [ ! -r "${FILMDATEI}" ] ; then
        	echo "Der Film '${FILMDATEI}' konnte nicht gefunden werden. Abbruch!"
        	exit 1
	else
		case "${FILMDATEI}" in
        		[a-zA-Z0-9\_\-\+/][a-zA-Z0-9\_\-\+/]*[.][Mm][Kk][Vv])
                		shift

				MKV_NEU="${FILMDATEI}"
                		;;
        		*)
				# ${PROGRAMM} -fflags +genpts ${FILMDATEI} -c:v copy -c:a copy -f matroska -y ${NAME_NEU}.mkv
				echo "
				${PROGRAMM} ${FILMDATEI} -c:v copy -c:a copy -f matroska -y ${FILMDATEI}.mkv
				"
				${PROGRAMM} ${FILMDATEI} -c:v copy -c:a copy -f matroska -y ${FILMDATEI}.mkv
                		shift

				MKV_NEU="${FILMDATEI}.mkv"
                		;;
		esac

		MKV_TEILE="${MKV_TEILE} ${MKV_NEU}"
		unset MKV_NEU
	fi
done

#==============================================================================#
### Filmteile aneinander reihen

FILM_TEILE="$(ls -1 ${MKV_TEILE} | tr -s '\n' '|' | sed 's/|/ + /g;s/ + $//')"

echo "
mkvmerge -o ${NAME_NEU}.mkv ${FILM_TEILE}
"
mkvmerge -o ${NAME_NEU}.mkv ${FILM_TEILE}

#------------------------------------------------------------------------------#

ls -lh ${NAME_NEU}.mkv ${NAME_NEU}.txt
exit
