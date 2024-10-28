#!/bin/bash

# 动态获取网卡名称（默认选择第一个非本地回环接口）
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n 1)

# 检查并添加MASQUERADE规则
if ! iptables -t nat -C POSTROUTING -o "$INTERFACE" -j MASQUERADE 2>/dev/null; then
    iptables -t nat -A POSTROUTING -o "$INTERFACE" -j MASQUERADE
fi
