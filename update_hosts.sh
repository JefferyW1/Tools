#!/bin/bash

# 指定域名
target_domain="hkg12s28-in-f3.1e100.net"

# 获取域名的IP地址
ip_address=$(dig +short $target_domain)

# 如果没有找到IP地址，输出错误信息并退出
if [ -z "$ip_address" ]; then
  echo "无法获取 $target_domain 的IP地址。"
  exit 1
fi

# 添加IP地址和对应的主机名到hosts文件的最上层位置
echo "$ip_address    www.gstatic.com" | sudo tee -a /etc/hosts > /dev/null

echo "成功将 $ip_address 添加到 /etc/hosts 文件的最上层位置。"
