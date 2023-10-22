#!/bin/bash

# 显示当前虚拟内存大小
echo "当前虚拟内存大小为："
free -h | grep 'Swap'

# 询问用户是否更改
read -p "是否需要更改虚拟内存大小？(y/n): " response

# 根据用户输入执行相应操作
if [[ $response == "y" ]]; then
    read -p "请输入新的虚拟内存大小（如1G, 2G等）: " new_swap_size
    # 禁用交换空间
    sudo swapoff /swapfile
    sudo fallocate -l "$new_swap_size" /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo "/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab
    echo "虚拟内存大小已成功更改，并已设置随系统启动。"
elif [[ $response == "n" ]]; then
    echo "不进行更改。"
else
    echo "无效的输入。"
fi
