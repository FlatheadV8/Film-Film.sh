#!/usr/bin/env bash

#VERSION="v2017050501"
#VERSION="v2018082600"
VERSION="v2019082700"

#------------------------------------------------------------------------------#

hilfe()
{
echo "#
# Mit diesem Skript kann man mehrere Filmteile aneinander reihen.
# Allerdings sollte man darauf achten, dass alle Teile zueinander kompatibel
# sind, sonst kann es beim abspielen zu Problemen kommen.
#
# Es ist darauf zu achten, dass diese Filmteile mindestens die gleiche
# Bildschirmauflösung, Bildwiederholrate und Codecs besitzen.
# Die Filmteile müssen auch in ihren Audio-Spuren gleichviele Kanäle haben.
# Zum Beispiel sollten alle Stereo (2) oder Dolby (6) haben.
# Beides gemischt geht nicht.
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
# (https://github.com/FlatheadV8/Film2MP4).
# Dabei ist unbedingt darauf zu achten, dass Sie für alle Einzelteile jeweils
# genau die gleichen Angaben für diese beiden Parameter verwenden:
#   -soll_xmaly
#   -dar
# zum Beispiel würde man für 3 Teile dieses tun:
#   ~/bin/Film2MP4.sh -soll_xmaly 1920x1080 -dar 16:9 -q 1.avi -z 1.mp4
#   ~/bin/Film2MP4.sh -soll_xmaly 1920x1080 -dar 16:9 -q 2.avi -z 2.mp4
#   ~/bin/Film2MP4.sh -soll_xmaly 1920x1080 -dar 16:9 -q 3.avi -z 3.mp4
#   ~/bin/Film+Film.sh komplett 1.mp4 2.mp4 3.mp4
#
# Der fertige Film, aus diesem Beispiel, hat am Ende den Namen "komplett.mkv".
# Dieses Skript kann nur MKV-Dateien produzieren.
#
# Es ist auch sinnvoll , dass man mit dem MKV-Format arbeitet,
# andernfalls muss dieses Skript den entsprechenden Film-Teil
# vor dem zusammenfügen ersteinmal ins MKV-Format übersetzen (das ist aber nicht schlimm).
#
# Wichtig zu sagen an dieser Stelle ist auch, dass Filme, die mit libx264
# erzeugt wurden werden beim zusammenfühgen keine Probleme verursachen, Filme
# die mit dem (von FF) internen Codec h264 erzeugt wurden, können nach dem
# zusammenfühgen unbrauchbare Ergebnisse erzielen!
#
# Es werden folgende Programme von diesem Skript verwendet:
#  - ffmpeg
#  - mkvmerge (aus dem Paket mkvtoolnix)
#

Beispiel:
> ${0} Filmfertig [Filmteil1.mp4] [Filmteil2.mp4] [Filmteil3.mp4]
"
}

#------------------------------------------------------------------------------#

if [ -e "$1" ] ; then
        hilfe
        exit 2
fi

if [ "x$3" == x ] ; then
        hilfe
        exit 2
fi

#------------------------------------------------------------------------------#


#set -x
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

LANG=C          # damit AWK richtig rechnet

#==============================================================================#

if [ -z "$1" ] ; then
        echo "${0} Filmfertig [Filmteil1.mp4] [Filmteil2.mp4] [Filmteil3.mp4]"
        exit 1
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
                                # ${PROGRAMM} -fflags +genpts -i ${FILMDATEI} -c:v copy -c:a copy -f matroska -y ${NAME_NEU}.mkv
                                echo "
                                ${PROGRAMM} -i ${FILMDATEI} -c:v copy -c:a copy -f matroska -y ${FILMDATEI}.mkv
                                "
                                ${PROGRAMM} -i ${FILMDATEI} -c:v copy -c:a copy -f matroska -y ${FILMDATEI}.mkv
                                shift

                                MKV_TEMP="${MKV_TEMP} ${FILMDATEI}.mkv"
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

for A in ${MKV_TEMP}
do
        echo "${A} -> $(mediainfo ${A} | egrep '^Channel[(]s[)]' | sed 's/  */ /g')"
done
rm -v ${MKV_TEMP}

echo

ls -lh ${NAME_NEU}.mkv ${NAME_NEU}.txt
exit
