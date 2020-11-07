 #Path to Directory
Vpn_Gate_Dir=./vpn_gate
Script_Dir=./scripts
Log_Dir=./vpn_log
Ovpn_Dir=$Vpn_Gate_Dir/ovpn
Var_Dir=$Vpn_Gate_Dir/var
Ip_Dir=$Vpn_Gate_Dir/ip

#File Name
Vpn_File_Name=$Ovpn_Dir/vpn_$iso\_$ip\_.ovpn
Vpn_Config_File=$Vpn_Gate_Dir/vpn_conf.txt
Info_Vpn_File=$Var_Dir/Info_Vpn.txt
Header_File=$Vpn_Gate_Dir/header.txt
Log_File=$Log_Dir/vpngate_openvpn.log


#File size
#Vpn_Config_Size=$(stat -c%s $Vpn_Config_File 2> /dev/null)

#myip=$(curl -s -4 ifconfig.co)
vgate=http://www.vpngate.net/api/iphone/

Start_File=0

Start_Clean=0

Start_Update=0

Echo_Info=0

No_Start=0

Queit=0

counter=0
