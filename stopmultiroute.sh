#!/bin/bash

ROUTECMD="ip route add default \\
          "
LOCALGATE='59.77.33.1'
LOCALIP='59.77.33.124'

#./vpn.sh
./delroute.sh

# disable routing cache
echo 1000 > /proc/sys/net/ipv4/rt_cache_rebuild_count


#declare -a IP_PPP

ip rule flush
#ip rule del prio 0 from all lookup main &> /dev/null
#ip rule del prio 0 from all lookup default &> /dev/null
ip rule add prio 32766 from all lookup main
ip rule add prio 32767 from all lookup default

# connect all xl2p vpn
for i in $(seq 0 1)
do

    IP_PPP=$(ip route | grep ppp${i} | awk '{print $9}')

    echo -n "modify routing table... "
    ip route flush table P${i}
    echo "OK"


    iptables -D INPUT -i ppp${i} -j ACCEPT
    iptables -D FORWARD -i ppp${i} -j ACCEPT

    iptables -t nat -D POSTROUTING -o ppp${i} -j SNAT --to ${IP_PPP}

   # pkill -f "upnpd ppp${i}"

    echo "stopping ppp$i"
    echo "d mb${i}" > /var/run/xl2tpd/l2tp-control
done



#echo -n "tun0 ... " 
#ip route flush table T0
#ip route add $(ip route show table main | grep 'tun0.*src') table T0
#ip route add default via 10.8.0.33 table T0
#
#ip rule add prio 30000 from 10.8.0.34 table T0
#iptables -A INPUT -i tun0 -j ACCEPT
#ROUTECMD="${ROUTECMD} nexthop via 10.8.0.33 dev tun0  weight 80 "
#
#echo "OK"

echo -n "eth0 ... " 
ip route flush table E0

iptables -D INPUT -i eth0 -j ACCEPT
iptables -D FORWARD -i eth0 -j ACCEPT

echo "OK"

# PPP DNS
ip route del 222.47.62.142
ip route del 222.47.29.93


ip route del default
ip route add default via $LOCALGATE

#ip route add default \
#nexthop via 10.8.0.33 dev tun0  weight 40 \
#nexthop via ${GATE} dev ppp0  weight 25 \
#nexthop via ${GATE} dev ppp1  weight 25 \
#nexthop via ${GATE} dev ppp2  weight 25 \
#nexthop via ${GATE} dev ppp3  weight 25 
#
