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

# 临时文件，用于存储新的 hosts 文件内容
temp_file=$(mktemp)

# 在临时文件中插入新的IP地址和对应的主机名
echo "$ip_address    www.gstatic.com" | cat - /etc/hosts > "$temp_file"

# 将临时文件内容覆盖到 /etc/hosts 文件
sudo cp "$temp_file" /etc/hosts

# 删除临时文件
rm "$temp_file"

echo "成功将 $ip_address 添加到 /etc/hosts 文件的第一行。"
