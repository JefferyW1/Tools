command -v sed >/dev/null 2>&1 || (apt update && apt install -y sed) && \

sed -i '/tcp_keepalive_time/d' /etc/sysctl.conf && \
sed -i '/tcp_keepalive_intvl/d' /etc/sysctl.conf && \
sed -i '/tcp_keepalive_probes/d' /etc/sysctl.conf && \
sed -i '/tcp_fin_timeout/d' /etc/sysctl.conf && \
sed -i '/tcp_tw_reuse/d' /etc/sysctl.conf && \

echo "net.ipv4.tcp_keepalive_time = 60" >> /etc/sysctl.conf && \
echo "net.ipv4.tcp_keepalive_intvl = 10" >> /etc/sysctl.conf && \
echo "net.ipv4.tcp_keepalive_probes = 7" >> /etc/sysctl.conf && \
echo "net.ipv4.tcp_fin_timeout = 15" >> /etc/sysctl.conf && \
echo "net.ipv4.tcp_tw_reuse = 1" >> /etc/sysctl.conf && \

sysctl -p
