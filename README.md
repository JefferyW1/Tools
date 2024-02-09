# Change_swap_size
debian 更改虚拟内存大小并开机启动
```
sudo curl -o /root/Change_swap_size.sh https://raw.githubusercontent.com/JefferyW1/Tools/main/Change_swap_size.sh && sudo chmod +x /root/Change_swap_size.sh && ./Change_swap_size.sh
```
# update_hosts
获取香港区域 www.gstatic.com DNS ，并写入hsots，用于降低测速延迟； 需要安装dig
dig安装命令
```
sudo apt-get install dnsutils  # 对于Debian/Ubuntu系统
```
```
sudo curl -o /root/update_hosts.sh https://raw.githubusercontent.com/JefferyW1/Tools/main/update_hosts.sh && sudo chmod +x /root/update_hosts.sh && ./update_hosts.sh
```
