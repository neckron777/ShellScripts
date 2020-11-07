#!/bin/bash

ProgramDir=$HOME/Programs/sh/autovpn-sh
cd $ProgramDir

source ./vpn_free/var/var.sh

function UpdateFiles {
	if [[ "$LastDate" != "$NewDate" ]]; then
		echo "Update Login:Password"
		curl -s $FreeVpn > $FreeVpnFile
		grep  -o "Username.*TCP" | sed -n '1h;2~1H;${g;s/<[^>]*>/ /g;p}' | tr " " "\n" | sed 's/^U.*//;s/^P.*//;/TCP/d;/^$/d' > $UserPassFile
		sed  's/LastDate=.*/LastDate="$NewDate"/' $VarFile
	else
		echo "OK"
	fi
	if [[ "$LastVpnDate" == "$NewVpnDate" ]]; then
		sed 's/LastVpnDate=.*/LastVpnDate="$LastVpnDate"/'
		echo "Update Vpn File"
		cd $VpnDir
		wget -q -O $ZipFile "https://freevpn.me/FreeVPN.me-OpenVPN-Bundle.zip"
		unzip -x $ZipFile > /dev/null
		rm $ZipFile
		mv "1 - FreeVPN.me"/  $VpnMe/
		mv "2  - FreeVPN.se"/ $VpnSe/
		cd - > /dev/null
	else
		echo "OK"
	fi
}

UpdateFiles
