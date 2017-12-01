#!/bin/bash
#Author by Yifeng Han
set -e

# Custom connection VPN username password
if [ -n "$VPNUSER" ] &&  [ -n "$VPNPASS" ];then
    add-user "$VPNUSER:$VPNPASS"
fi

# Dynamic modification of IPSec.conf
sed -i "s/\$LEFTID/$HOSTIP/g" /usr/local/etc/ipsec.conf

# Preload iptables,Rule lost when preventing restart of container!
iptables-restore < /etc/sysconfig/iptables

# Repair gcp container restart, can not access google family bucket(Disable pmtu discovery!)
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv4.ip_no_pmtu_disc=1

# Create certificate if not exist
if [ ! -e /data/key_files/ca.cert.pem ];then
    /usr/bin/generate-key
fi

# Apply the certificate
/usr/bin/apply-key

exec "$@"
