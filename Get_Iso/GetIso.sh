#!/bin/bash

KaliDL="http://cdimage.kali.org"
UbuntuDL=""
ArchDL=""
DebianDL=""
declare FILE
Get() {
	if [[ "$1" == "Kali" || "$1" == "kali" ]] ; then
		URL=$KaliDL
		FILE=$(curl -s $URL/kali-$VERS/ | sed -e 's/.*<a href="//;s/">.*//;s/^<.*//;/^$/d;/^ .*/d;/^\?.*/d;/^\/.*/d' |  grep "$FORM" | grep "$ARCH" |  grep "$DE")
		[[ ! -n $DE ]] && 
		echo "$FILE"
	fi
}

checkargs() {
        if [[ $OPTARG =~ ^-[a-zA-Z]$ ]] ; then
                echo "Unknown argument $OPTARG for option $opt!"
                exit 1
        fi
}

while getopts "d:V:e:f:a:" opt
do
        case $opt in
                d ) checkargs ; DIST=$OPTARG
                ;;
                V ) checkargs ; VERS=$OPTARG
                ;;
		e ) checkargs ; DE=$OPTARG
		;;
		f ) checkargs ; FORM=$OPTARG
		;;
                a ) checkargs ; ARCH=$OPTARG
		;;

        esac
done

Get $DIST

#Kali#curl -s $URL | sed -e 's/.*<a href="//;s/">.*//;s/^<.*//;/^$/d;/^ .*/d;/^\?.*/d;/^\/.*/d' | tr '\n' ' '
