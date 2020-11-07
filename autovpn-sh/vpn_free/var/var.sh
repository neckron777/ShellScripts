#DIR
VpnDir=./vpn_free
VpnMe=me
VpnSe=se
VarDir=$VpnDir/var

#FILES
FreeVpnFile=$VpnDir/freevpnme
UserPassFile=$VpnDir/UserPass
VarFile=$VarDir/var.sh
ZipFile=FreeVpn.zip

#VARS
FreeVpn=https://freevpn.me/accounts/
NewVpnDate=$(grep -o "Updated.*," $FreeVpnFile | sed 's/Download.*// ; s/Updated// ; s/,// ; s/\s//g')
LastVpnDate=May212017
NewDate=$(date +%D)
LastDate=01/24/18
