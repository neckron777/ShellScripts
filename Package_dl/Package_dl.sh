#!/bin/bash

Ubuntu(){

	if [[ ! -f ./Ubuntu ]] ; then
        	mkdir Ubuntu &> /dev/null
	fi

	Search() {
		array=($(echo "$PACK" | fold -w1))
		if [[ ${array[0]} == "l" ]] ; then
        		if [[ ${array[1]} == "i" ]] ; then
                		if [[ ${array[2]} == "b" ]] ; then
                        		array=($( echo "$1" | fold -w4 ))
                		fi
        		fi
		fi
		deb=($(curl -s "http://archive.ubuntu.com/ubuntu/pool/$REPO/${array[0]}/$PACK/" | grep "$FORM" | sed -e 's/.*<a href="//;s/">.*//;s/^<.*//;/^$/d;/^ .*/d;/^\?.*/d;/^\/.*/d' | tr '\n' ' '))
		deb_num=${#deb[@]}
		if [[ $deb_num == "0" ]] ; then
			echo "Nothing found "
			exit 1
		fi

		for (( i=0 ; $i < $deb_num ; i++ ))
		do
			echo "${deb[$i]} ($i)"
		done
	}

	Download() {
		Search
		echo -n "File [num]: "
		read num_file
		if [[ $num_file =~ ^[a-zA-Z]{1,}$ ]] ; then
			echo "Enter the number: "
			exit 1
		fi
		wget -P ./Ubuntu http://archive.ubuntu.com/ubuntu/pool/$REPO/${array[0]}/$PACK/${deb[$num_file]}
	}

	if [[ $SEARCH ]] ; then
        	Search
	fi

	Download
}

Arch() {

	if [[ ! -f ./Arch ]] ; then
		mkdir ./Arch &> /dev/null
	fi

	Search() {
		curl -s "https://mirrors.edge.kernel.org/archlinux/$REPO/os/x86_64/" | grep "$PACK" | sed -e 's/<a.*=//;s/">.*//;s/<.*//;s/"//;/^$/d'
	}

	Search
}

checkargs() {
	if [[ $OPTARG =~ ^-[a-zA-Z]$ ]] ; then
        	echo "Unknown argument $OPTARG for option $opt!"
        	exit 1
        fi
}

while getopts "d:r:a:p:f:s" opt
do
	case $opt in
		d ) checkargs ; DIST=$OPTARG
		;;
		r ) checkargs ; REPO=$OPTARG
		;;
		a ) checkargs ; ARCH=$OPTARG
		;;
		p ) checkargs ; PACK=$OPTARG
		;;
		f ) checkargs ; FORM=$OPTARG
		;;
		s ) SEARCH=true
		;;

	esac
done

if [[ ! "$REPO" ]] ; then
        echo "Specify the repository"
        exit 1
fi

if [[ ! "$PACK" ]] ; then
        echo "Provide package name"
	exit 1
fi

[[ $DIST == "ubuntu" ]] && Ubuntu
[[ $DIST == "arch" ]] && Arch

#if [[ ! -f ./Ubuntu/Packages ]] ; then
#       	wget -P ./Ubuntu "http://archive.ubuntu.com/ubuntu/dists/$DIST/$REPO/$ARCH/Packages.xz"
#        xz -d Packages.xz
#	grep  "Filename" Packages > Filename
#fi
#curl -s "https://mirrors.edge.kernel.org/archlinux/"|sed 's/<a.*=//;s/">.*//;s/<.*//;s/"//;s///'
