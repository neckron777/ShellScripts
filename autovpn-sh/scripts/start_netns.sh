#!/bin/bash

start()
{
	echo "  [SN]Создается netns"
	ip netns add vpn
        ip netns exec vpn ip link set lo up
	echo "  [SN]Создается VIF"
        ip link add vpn0 type veth peer name vpn1
        ip link set vpn0 up
        ip link set vpn1 netns vpn up
        ip addr add 10.10.10.1/24 dev vpn0
	echo "	[SN]Добавляются правила маршрутизации"
        ip netns exec vpn ip addr add 10.10.10.2/24 dev vpn1
        ip netns exec vpn ip route add default via 10.10.10.1 dev vpn1
	echo "	[SN]Добавляются правила iptables"
        iptables -A INPUT ! -i vpn0 -s 10.10.10.0/24 -j DROP
        iptables -t nat -A POSTROUTING -s 10.10.10.0/24 -o wl+ -j MASQUERADE
}

case $1 in
	start ) start
	;;
esac

