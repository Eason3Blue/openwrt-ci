rm -rf package/emortal/luci-app-athena-led
git clone --depth=1 https://github.com/NONGFAH/luci-app-athena-led package/luci-app-athena-led
chmod +x package/luci-app-athena-led/root/etc/init.d/athena_led package/luci-app-athena-led/root/usr/sbin/athena-led

#!/bin/bash

cd $OPENWRT_PATH

# 网络 backlog
mkdir -p files/etc/sysctl.d

cat > files/etc/sysctl.d/99-router.conf <<EOF
net.core.netdev_max_backlog=8192
net.core.rmem_max=67108864
net.core.wmem_max=67108864
net.ipv4.tcp_congestion_control=bbr
net.ipv4.tcp_fastopen=3
net.netfilter.nf_conntrack_max=262144
EOF


# CPU performance governor
mkdir -p files/etc/init.d

cat > files/etc/init.d/cpu-perf <<'EOF'
#!/bin/sh /etc/rc.common
START=10
start() {
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
 echo performance > $cpu
done
}
EOF

chmod +x files/etc/init.d/cpu-perf


# RPS/XPS
cat > files/etc/init.d/rps <<'EOF'
#!/bin/sh /etc/rc.common
START=99
start() {
for q in /sys/class/net/eth0/queues/rx-*; do
 echo f > $q/rps_cpus
done
for q in /sys/class/net/eth0/queues/tx-*; do
 echo f > $q/xps_cpus
done
}
EOF

chmod +x files/etc/init.d/rps