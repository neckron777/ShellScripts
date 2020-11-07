#!/bin/bash

split_into_parts() {

        part1="$1"
        part2="$2"
        part2="$3"
}
start()
{
	 for option_var_name in ${!foreign_option_*} ; do
                option="${!option_var_name}"
                echo "$option"
                split_into_parts $option

                if [ "$part1" = "dhcp-option" ] ; then
                        if [ "$part2" = "DNS" ]; then
                                DNS="$part3"
                                echo "nameserver $DNS" >> /etc/netns/vpn/resolv.conf
                        elif [ "$part2" = "DOMAIN" ]; then
                                DNS="$part3"
                                echo "search $DNS" >> /etc/netns/vpn/resolv.conf
                        fi
                fi
        done
}

stop()
{
	rm -r /etc/netns/vpn

	iptables -D INPUT ! -i vpn0 -s 10.10.10.0/24 -j DROP
	iptables -t nat -D POSTROUTING -s 10.10.10.0/24 -o wl+ -j MASQUERADE

	ip link del vpn0
	ip netns del vpn
}
case "$script_type" in
	up ) start
	;;
	down ) stop
	;;
esac

