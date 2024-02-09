#!/bin/bash

# 目标域名
target_domain="hkg12s28-in-f3.1e100.net"
# 本机hosts文件路径
hosts_file="/etc/hosts"
# 映射的域名
mapped_domain="www.gstatic.com"

# 获取目标域名的IP地址
ip_address=$(dig +short "$target_domain")

# 检查是否成功获取到IP地址
if [ -n "$ip_address" ]; then
    # 检查是否已经存在映射关系，如果存在则删除旧的映射
    existing_mapping=$(grep -E "\s+$mapped_domain\s*$" "$hosts_file")
    if [ -n "$existing_mapping" ]; then
        sudo sed -i "/\s$target_domain\s*/d" "$hosts_file"
    fi

    # 添加新的映射
    sudo bash -c "echo '$ip_address    $mapped_domain' >> $hosts_file"
    echo "Hosts文件已更新，$target_domain 的IP地址映射到 $mapped_domain"
else
    echo "无法获取 $target_domain 的IP地址"
fi
