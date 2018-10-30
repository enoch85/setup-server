# Change DNS system wide
sed -i "s|#DNS=.*|DNS=9.9.9.9 2620:fe::fe|g" /etc/systemd/resolved.conf
sed -i "s|#FallbackDNS=.*|FallbackDNS=149.112.112.112 2620:fe::9|g" /etc/systemd/resolved.conf
check_command systemctl restart network-manager.service
network_ok
