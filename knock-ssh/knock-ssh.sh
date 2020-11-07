#!/bin/bash

PR_DIR=~/Dev/sh/knock-ssh

Creat_Config() {
	CN=$PR_DIR/conf/$1.conf

	if [[ ! -f $CN ]] ; then
		echo "Create conf file"
                touch $CN
        fi

	change_conf() {

		name=$1
		if [[ "$name" == "knocks" ]] ; then
			option=($2)
			if grep "$name" $CN &> /dev/null ; then
                        	sed -i "s/$name=.*/$name=\(${option[*]}\)/" $CN
                	else
                        	echo "$name=(${option[*]})" >> $CN
                	fi
		else
			option=$2

			if grep "$name" $CN &> /dev/null ; then
                		sed -i "s/$name=.*/$name=$option/" $CN
        		else
                		echo "$name=$option" >> $CN
        		fi
		fi
	}

	echo -n "Specify ip: "
	read opt
	change_conf ip $opt

	echo -n "Specify user name: "
	read opt
	change_conf user $opt

	echo -n "Specify port: "
	read opt
	change_conf port $opt

	echo -n "Specify ports for knock: "
	read -a opt
	change_conf "knocks" "${opt[*]}"
}

Get_Config() {
	if [[ ! -n $1 ]] ; then
		echo "Error: Specify file name"
		exit
	else
		file=$PR_DIR/conf/$1.conf
	fi

	if [[ -f $file  ]] ; then
		source $file
	else
		echo "Error: File not Found"
		exit
	fi
}

Remove_Config() {

	if [[ ! -n $1 ]] ; then
		echo "Error: Specify file name"
		exit
	else
		file=$PR_DIR/conf/$1.conf
	fi

	if [[ -f $file ]] ; then
	  echo -n "Are you sure you want to delete the file [y/n]: "
	  read RMC
	  if [[ "$RMC" == "y" ]] ; then
		rm $file
	  fi

}

checkargs() {
        if [[ $OPTARG =~ ^-[a-zA-Z]$ ]] ; then
                echo "Error: Unknown argument $OPTARG for option $opt!"
                exit 1
        fi
}

while getopts "i:u:k:p:C:c:r:ls" opt
do
	case $opt in
		i ) checkargs ; ip=$OPTARG
		;;
		u ) checkargs ; user=$OPTARG
		;;
		k ) checkargs ; knocks=($OPTARG)
		;;
		p ) checkargs ; port=$OPTARG
		;;
		r ) checkargs ; Remove_Config $OPTARG
		;;
		c ) checkargs ; Get_Config $OPTARG
		;;
		C ) checkargs ; Creat_Config $OPTARG
		;;
		l ) ls $PR_DIR/conf/ && exit
		;;
		s ) START=1
		;;
	esac
done
Num=0

[[ ! $START ]] && exit

[[ ! -n "$ip"   ]] || Num=$(( $Num + 1 ))

[[ ! -n "$user" ]] || Num=$(( $Num + 1 ))

[[ ! -n "$port" ]] || Num=$(( $Num + 1 ))

if [[ "$Num" == 3 ]] ; then
	if  [[ ${#knocks[@]} != 0 ]] ; then
		knock $ip ${knocks[*]} &> /dev/null
	else
		echo "Error: Specify ports for knock"
	fi
	sleep 1
	ssh $user@$ip -p $port
else
	echo "Error: Check configuration or arguments"
fi

#fwknop -A tcp/22 -a 192.168.5.8 -D 192.168.5.34 --key-gen --use-hmac --save-rc-stanza
#fwknop -n 192.168.5.34 -a 192.168.5.8 --verbose
