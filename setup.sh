#!/bin/bash

# 更新系统并安装基础工具
echo "更新系统并安装基础工具..."
apt-get install ca-certificates wget -y 
update-ca-certificates
&& apt update -y 
&& apt full-upgrade -y 
&& apt autoremove -y 
&& apt autoclean -y 
&& apt install -y curl 
&& apt install -y socat 
&& apt install wget -y 
&& apt install sudo 
&& sudo apt install curl 
# 修改时区为上海
echo "修改时区为上海..."
&& sudo timedatectl set-timezone Asia/Shanghai 
# 卸载自动更新-移除不必要的软件包
echo "卸载自动更新-移除不必要的软件包..."
&& sudo apt remove unattended-upgrades -y 
# 心跳包
echo "心跳包..."
&& bash <(curl -sSL https://raw.githubusercontent.com/wikihost-opensource/linux-toolkit/main/network/ssh-server-heartbeat.sh) 
# 生成证书文件夹
echo "生成证书文件夹..."
&& mkdir /root/cert 
&& chmod -R 755 /root/cert 
&& mkdir /root/mycert 
&& chmod -R 755 /root/mycert 
# 安装xrayr
echo "安装xrayr..."
&& wget -N https://raw.githubusercontent.com/XrayR-project/XrayR-release/master/install.sh && bash install.sh 
# 安装iptables
echo "安装iptables..."
&& apt-get install iptables 
# 安装证书脚本
echo "安装证书脚本..."
&& curl https://get.acme.sh | sh 
# 安装unzip
echo "安装unzip..."
&& sudo apt-get install -y zip unzip 
# 安装tuned开机自启设置高吞吐低延迟网络优化
echo "安装tuned开机自启设置高吞吐低延迟网络优化..."
&& apt install -y tuned && sudo systemctl start tuned.service && sudo systemctl enable tuned.service && tuned-adm profile network-throughput network-latency 
# 启用 TCP Timestamps-
echo "启用 TCP Timestamps..."
&& sysctl -w net.ipv4.tcp_timestamps=1 
# 启用 TCP 优化(参考pfgo)
echo "启用 TCP 优化(参考pfgo)..."
&& bash <(curl -sL "https://scripts.zeroteam.top/PortForwardGo/tcp.sh") 
# 配置iptable NAT隐藏ip-\ 配置iptable NAT定时任务持久化
echo "配置iptable NAT隐藏ip-\ 配置iptable NAT定时任务持久化..."
&& sudo curl -o /root/masquerade.sh https://raw.githubusercontent.com/JefferyW1/Tools/main/masquerade.sh && sudo chmod +x /root/masquerade.sh && ./masquerade.sh 
&& crontab -l > mycron && echo "*/5 * * * * /root/masquerade.sh" >> mycron && crontab mycron && rm mycron
echo "全部执行完成"
