#!/bin/bash
# 测试常见邮局服务器的端口连通性
# 适用于检测：Gmail / Outlook / QQ邮箱 / 163邮箱 等

servers_and_ports=(
  "smtp.gmail.com:25"
  "smtp.gmail.com:465"
  "smtp.gmail.com:587"

  "smtp-mail.outlook.com:587"             # Outlook SMTP
  "outlook.office365.com:993"             # Outlook IMAP
  "outlook.office365.com:995"             # Outlook POP

  "smtp.qq.com:25"
  "smtp.qq.com:465"
  "smtp.qq.com:587"

  "smtp.163.com:25"
  "smtp.163.com:465"
  "smtp.163.com:587"
)

echo "=== 邮局端口连通性检测报告 ==="
for entry in "${servers_and_ports[@]}"; do
  server=${entry%%:*}
  port=${entry##*:}
  printf "\n🔍 正在测试 %-30s 端口 %-5s ..." "$server" "$port"
  
  result=$(nc -vz -w 5 $server $port 2>&1)
  
  if echo "$result" | grep -q "succeeded"; then
    echo " ✅ 可连接"
  elif echo "$result" | grep -q "refused"; then
    echo " ⚠️ 连接被拒绝（目标服务器拒绝）"
  elif echo "$result" | grep -q "timed out"; then
    echo " ❌ 超时（端口可能被封）"
  else
    echo " ❓ 未知状态：$result"
  fi
done
echo -e "\n=== 检测完成 ==="
