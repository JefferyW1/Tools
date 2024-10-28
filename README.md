# Change_swap_size
debian 更改虚拟内存大小并开机启动
```
sudo curl -o /root/Change_swap_size.sh https://raw.githubusercontent.com/JefferyW1/Tools/main/Change_swap_size.sh && sudo chmod +x /root/Change_swap_size.sh && ./Change_swap_size.sh
```
# masquerade
配置iptable NAT（特别是源网络地址转换，SNAT），可以将用户的真实IP转换为VPN服务器的IP地址
```
sudo curl -o /root/masquerade.sh https://raw.githubusercontent.com/JefferyW1/Tools/main/masquerade.sh && sudo chmod +x /root/masquerade.sh && ./masquerade.sh
```
配合此定时任务，每5分钟执行一次，使得此确保iptables规则持久化
```
crontab -l > mycron && echo "*/5 * * * * /root/masquerade.sh" >> mycron && crontab mycron && rm mycron
```

# update_hosts
获取香港区域 www.gstatic.com DNS ，并写入hsots，用于降低测速延迟； 需要安装dig
```
sudo apt-get install dnsutils  # dig安装命令 对于Debian/Ubuntu系统
```
```
sudo curl -o /root/update_hosts.sh https://raw.githubusercontent.com/JefferyW1/Tools/main/update_hosts.sh && sudo chmod +x /root/update_hosts.sh && ./update_hosts.sh
```
