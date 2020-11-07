#!/bin/bash

if [[ $(whoami) != 'root' ]];then
	echo "У вас нет прав для запуска $0"
	exit 1
fi

Program_Dir=/home/neckron/Dev/Linux/MY/sh/autovpn-sh
cd $Program_Dir

source ./vpn_gate/var/var.sh

if [ $# -lt 1 ]; then
        echo "Команд не найдена!"
        exit 1
fi

checkargs() {
if [[ $OPTARG =~ ^-[a-zA-Z]$ ]]
        then
        echo "Неизвестный аргумент $OPTARG для опции $opt!"
        exit 1
        fi
}

while getopts "i:nfcueEFS" opt
do
	case $opt in
		i ) checkargs ; iso=$OPTARG
		;;
		n ) No_Start=1
		;;
		f ) Start_File=1
		;;
		c ) Start_Clean=1
		;;
		u ) Start_Update=1
		;;
		e ) Echo_Info=1
		;;
		E ) Echo_Iso=1
		;;
		F ) checkargs ; speed_var=$OPTARG ;Filter=1
		;;
		S ) Speed=1
		;;
   		* ) echo "Неправильная команда" ; exit 1
		;;
  	esac
done

function Download_Conf {
	if [[ ! -e $Vpn_Config_File ]]; then
		echo "Скачивается файл конфигурации Vpn"
        	curl -s $vgate > $Vpn_Config_File
	fi
}

function Extract_Header {
	if [[ ! -e $Header_File ]]; then
        	echo "Извлечение заголовков"
        	cat $Vpn_Config_File | sed 's/Iy.*//' > $Header_File
	fi
}

function Update_Conf {
	rm $Vpn_Config_File > /dev/null
	rm $Header_File > /dev/null
	echo "Обновление файла конфигурации Vpn"
	curl -s $vgate > $Vpn_Config_File
	sleep 1

	Extract_Header
	sleep 1
	exit
}

function Extract_Iso {
	all_iso=$(cut -f7 -d "," $Header_File | sed -e '/^\*/d ; /CountryShort/d ; /vpn_servers/d' | sort -u)
	#all_iso=($( sort -u <<< "${all_iso[@]}" ))
	all_iso_sum=${#all_iso[@]}
}

function Echo_Speed {
	speed_ping=$(cut -f4 -d "," $Header_File | sed -e 's/Ping//;s/\*.*//;/ /d;/^$/d;/-/d;' | sort -nru)
	echo "${speed_ping[@]}"
	exit
}

function Auto_Start {

#	function No_iso {
#
#	}

	function Extract_Ip {
		Ip_File=$Vpn_Gate_Dir/$iso.txt
		if [[ "$Filter" == "" ]]; then
			grep "\,$iso\," $Header_File | grep -E -o "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" > $Ip_File
		else
			grep "\,$speed_var\," $Header_File | grep -E -o "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" > $Ip_File
		fi
		ip=($(cat $Ip_File))
		ip_sum=${#ip[@]}
	}


	Extract_Ip

	if [[ $ip_sum == 0 ]]; then
		echo "Kод страны не найден"
		rm $Ip_File
		exit 1
	fi

	ip_sum=$(( --ip_sum ))
	random_ip=$RANDOM
	let "random_ip %= $ip_sum"
	ip="${ip[$random_ip]}"
	sleep 1
	echo "Выброный IP ($ip)"
	Vpn_File_Name=$Ovpn_Dir/vpn_$iso\_$ip\_.ovpn

	rm $Ip_File

	function Start_Vpn {
		sleep 1
        	echo "Создание Файла Конфигурации"
	        grep "$ip" $Vpn_Config_File | sed 's/.*,//' | base64 -i -d > $Vpn_File_Name

    		if [[ "$No_Start" == 0 ]]; then
			sleep 1
			echo "Запуск vpn"
        		#gnome-terminal -e "openvpn $Vpn_File_Name"
			openvpn $Vpn_File_Name
		fi
	}

	Start_Vpn
}
function Start_Vpn_File {

	Existing_Vpn=($(ls $Ovpn_Dir/ ))
        Existing_Vpn_sum=${#Existing_Vpn[@]}

	if [[ $Existing_Vpn_sum == 0 ]]; then
		echo "Файлов конфигурации не найдено"
		exit 1
	fi

        for (( i=0; i < $Existing_Vpn_sum ; i++ ))
        do
        	echo "Vpn: ${Existing_Vpn[$i]} ($i)"
	done

        echo ""
	echo -n "Bыберите vpn: "
        read vpn_num

	file_iso=$(echo "${Existing_Vpn[$vpn_num]}" | sed -e 's/vpn_// ; s/_.*$//')
	file_ip=$(echo "${Existing_Vpn[$vpn_num]}" | sed -e 's/vpn_[A-Z]..// ; s/_.*$//')
	iso=$file_iso
	ip=$file_ip

	if [ $vpn_num -lt $Existing_Vpn_sum ]; then
        	echo "Запуск ${Existing_Vpn[$vpn_num]}"
               	screen -dmS vpn openvpn $Ovpn_Dir/${Existing_Vpn[$vpn_num]}
        else
                echo "Ошибка: Файл не найден"
               	exit 1
	fi
}
function Restart_Vpn {
	sleep 14
	myip=$(curl -s -4 ifconfig.co)

	if [[ -z "$myip" ]];then
		echo "Error myip"
		echo "myip=$myip"
		exit 1;
	fi

	if [[ "$myip" != "$ip" ]]; then
		pid_vpn=($(pgrep openvpn))
		pid_vpn_sum=${#pid_vpn[@]}
		counter=$(( $counter + 1 ))

		if [[ "$pid_vpn_sum" != 0 ]]; then

			for (( pid=0 ; pid < $pid_vpn_sum ; pid++ ))
			do
				kill -INT "${pid_vpn[$pid]}"
			done

			echo ""
        		echo "Смена vpn конфигурации"

			if [[ $counter == 2 ]]; then
				counter=0
				Extract_Iso

				random_iso=$RANDOM
        			all_iso_sum=$(( $all_iso_sum - 1 ))
        			let "random_iso %= $all_iso_sum"

        			iso="${all_iso[$random_iso]}"

				echo "Kод страны изменен: $iso"
			fi

			Auto_Start=1
        		No_Ip
		else
			exit 1
		fi
	else
		exit
	fi
	Restart_Vpn
}

function Cleane_Files {
	ovpn_files=($( ls $Ovpn_Dir/ ))
	ovpn_sum=${#ovpn_files[@]}

	if [[ $ovpn_sum -ge 1 ]]; then
		ovpn_sum=$(( $ovpn_sum -1 ))
		for (( rv=0 ; rv <= $ovpn_sum ; ++rv ))
		do
			echo "Remove ${ovpn_files[$rv]}"
			sleep 1
			rm $Ovpn_Dir/"${ovpn_files[$rv]}"
		done
	else
		echo "File Not Found"
		exit 1
	fi
exit
}

function Vpn_Info {
	ov_pid=$(pgrep openvpn)
	#if [[ ! -z "$ov_pid" ]]; then
		curl -s ifconfig.co/json | sed 's/.*{//; s/,/\n/g ; s/.$/\n/; s/"//g'  > $Info_Vpn_File
		HError=($(grep -o "429"  $Info_Vpn_File))

		if [[ "$HError" == 429 ]]; then
			echo "Превышен лимит запросов к серверу ifconfig.co"
			exit 1
		fi

		info_ip=$(grep "ip:" $Info_Vpn_File | sed 's/^.*://')
		info_decimal=$(grep "ip_" $Info_Vpn_File | sed 's/^.*://')
		info_city=$(grep "^city" $Info_Vpn_File | sed 's/^.*://')
		info_country=$(grep "^count" $Info_Vpn_File | sed 's/^.*://')
		info_host=$(grep "^host" $Info_Vpn_File | sed 's/^.*://')

		echo "##############################################################"
		echo "#### Ip: $info_ip"
		echo "#### IP_Decimal: $info_decimal"
		echo "#### City: $info_city"
		echo "#### Country: $info_country"
		echo "#### HostName: $info_host"
		echo "##############################################################"
	#else
		#echo "Не найдено vpn соединений"
		#exit 1;
	#fi
exit
}

if [[ "$Speed" == 1 ]] ; then
	Echo_Speed
fi

if [[ "$Echo_Iso" == 1 ]]; then
	Extract_Iso
	echo "${all_iso[@]}"
	exit
fi

if [[ "$Start_Update" == 1 ]]; then
	Update_Conf
fi

if [[ "$Echo_Info" == 1 ]]; then
	Vpn_Info
fi

if [[ "$Start_Clean" == 1 ]]; then
	Cleane_Files
fi

if [[ "$Start_File" == 1 ]]; then
	Start_Vpn_File
     else
	Auto_Start
fi

exit
