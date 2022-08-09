#!/bin/bash

export IPT="iptables"

# Front end
export WAN=ens192
export WAN_IP=x.x.x.x

# The local network
export LAN1=ens224
export LAN1_IP_RANGE=10.1.1.0/24

# Cleaning up the rules
$IPT -F
$IPT -F -t nat
$IPT -F -t mangle
$IPT -X
$IPT -t nat -X
$IPT -t mangle -X

# We prohibit everything that is not allowed
$IPT -P INPUT DROP
$IPT -P OUTPUT DROP
$IPT -P FORWARD DROP

# Allow localhost and local network
$IPT -A INPUT -i lo -j ACCEPT
$IPT -A INPUT -i $LAN1 -j ACCEPT
$IPT -A OUTPUT -o lo -j ACCEPT
$IPT -A OUTPUT -o $LAN1 -j ACCEPT

# Allow pings
$IPT -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT
$IPT -A INPUT -p icmp --icmp-type destination-unreachable -j ACCEPT
$IPT -A INPUT -p icmp --icmp-type time-exceeded -j ACCEPT
$IPT -A INPUT -p icmp --icmp-type echo-request -j ACCEPT

# Allow outgoing server connections
$IPT -A OUTPUT -o $WAN -j ACCEPT
#$IPT -A INPUT -i $WAN -j ACCEPT

# Allow established connections
$IPT -A INPUT -p all -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPT -A OUTPUT -p all -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPT -A FORWARD -p all -m state --state ESTABLISHED,RELATED -j ACCEPT

# Dropping unrecognized packets
$IPT -A INPUT -m state --state INVALID -j DROP
$IPT -A FORWARD -m state --state INVALID -j DROP

# Dropping null packets
$IPT -A INPUT -p tcp --tcp-flags ALL NONE -j DROP

# Closing from syn-flood attacks
$IPT -A INPUT -p tcp ! --syn -m state --state NEW -j DROP
$IPT -A OUTPUT -p tcp ! --syn -m state --state NEW -j DROP

# We block access from the specified addresses
#$IPT -A INPUT -s 84.122.21.197 -j REJECT


# We drop intruders
#filter all FORWARD  $IPT -I FORWARD -j LOG --log-prefix "IPSET ALLOW"
$IPT -I FORWARD -m set --match-set ban src -j DROP
$IPT -I FORWARD -m set --match-set ban src -j LOG --log-prefix "IPSET BLOCK"


# Forwarding a port to LAN
$IPT -t nat -A PREROUTING -p tcp --dport 3390 -i ${WAN} -j DNAT --to 10.1.1.51:3389
$IPT -A FORWARD -i $WAN -d 10.1.1.51 -p tcp -m tcp --dport 3389 -j ACCEPT

$IPT -t nat -A PREROUTING -p tcp --dport 3391 -i ${WAN} -j DNAT --to 10.1.1.55:3389
$IPT -A FORWARD -i $WAN -d 10.1.1.55 -p tcp -m tcp --dport 3389 -j ACCEPT


# Allow access from the local area outside
$IPT -A FORWARD -i $LAN1 -o $WAN -j ACCEPT
# We close access from the outside to the local area
$IPT -A FORWARD -i $WAN -o $LAN1 -j REJECT

# Turn on NAT
$IPT -t nat -A POSTROUTING -o $WAN -s $LAN1_IP_RANGE -j MASQUERADE

# Opening access to SSH
#$IPT -A INPUT -i $WAN -p tcp --dport 3390 -j ACCEPT
#$IPT -A INPUT -i $WAN -p tcp --dport 3391 -j LOG --log-prefix "IP port 3391"
#$IPT -A INPUT -i $WAN -p tcp --dport 3391 -j DROP

#$IPT -A INPUT -i $WAN -p tcp --dport 3391 -j ACCEPT
$IPT -A INPUT -i $WAN -p tcp --dport 2200 -j LOG --log-prefix "IP DROP SSH 2200"
$IPT -A INPUT -i $WAN -p tcp --dport 2200 -j ACCEPT
$IPT -A INPUT -i $WAN -p tcp --dport 22 -j LOG --log-prefix "IP DROP SSH 22"
$IPT -A INPUT -i $WAN -p tcp --dport 22 -j DROP

$IPT -A INPUT -i $WAN -p tcp --dport 80 -j LOG --log-prefix "IP DROP WEB 80"
$IPT -A INPUT -i $WAN -p tcp --dport 80 -j DROP

# Opening access to the mail server
#$IPT -A INPUT -p tcp -m tcp --dport 25 -j ACCEPT
#$IPT -A INPUT -p tcp -m tcp --dport 465 -j ACCEPT
#$IPT -A INPUT -p tcp -m tcp --dport 110 -j ACCEPT
#$IPT -A INPUT -p tcp -m tcp --dport 995 -j ACCEPT
#$IPT -A INPUT -p tcp -m tcp --dport 143 -j ACCEPT
#$IPT -A INPUT -p tcp -m tcp --dport 993 -j ACCEPT

# Opening access to the web server
#$IPT -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
#$IPT -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT

# Opening access to the DNS server
#$IPT -A INPUT -i $WAN -p udp --dport 53 -j ACCEPT

# Turn on logging
#$IPT -N block_in
#$IPT -N block_out
#$IPT -N block_fw

#$IPT -A INPUT -j block_in
#$IPT -A OUTPUT -j block_out
#$IPT -A FORWARD -j block_fw

#$IPT -A block_in -j LOG --log-level info --log-prefix "--IN--BLOCK"
#$IPT -A block_in -j DROP
#$IPT -A block_out -j LOG --log-level info --log-prefix "--OUT--BLOCK"
#$IPT -A block_out -j DROP
#$IPT -A block_fw -j LOG --log-level info --log-prefix "--FW--BLOCK"
#$IPT -A block_fw -j DROP

# Save the rules
/sbin/iptables-save  > /etc/sysconfig/iptables