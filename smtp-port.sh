#!/bin/bash
# ============================================
# 邮局端口连通性检测脚本
# 检测常见邮箱的 SMTP / IMAP / POP 端口可达性
# 作者：ChatGPT (GPT-5)
# ============================================

servers_and_ports=(
  # Gmail 邮局
  "smtp.gmail.com:465"              # SMTP SSL
  "smtp.gmail.com:587"              # SMTP STARTTLS
  "imap.gmail.com:993"              # IMAP SSL
  "pop.gmail.com:995"               # POP SSL

  # Outlook / Office 365 邮局
  "smtp-mail.outlook.com:587"       # SMTP STARTTLS
  "outlook.office365.com:993"       # IMAP SSL
  "outlook.office365.com:995"       # POP SSL

  # QQ 邮箱
  "smtp.qq.com:465"                 # SMTP SSL
  "smtp.qq.com:587"                 # SMTP STARTTLS

  # 163 邮箱
  "smtp.163.com:465"                # SMTP SSL
  "smtp.163.com:587"                # SMTP STARTTLS
)

echo "=== 📬 邮局端口连通性检测报告 ==="
start_time=$(date +%s)

for entry in "${servers_and_ports[@]}"; do
  server=${entry%%:*}
  port=${entry##*:}
  printf "\n🔍 正在测试 %-30s 端口 %-5s ..." "$server" "$port"

  # 测试连通性并记录耗时
  t_start=$(date +%s%3N)
  result=$(nc -vz -w 5 $server $port 2>&1)
  t_end=$(date +%s%3N)
  duration=$((t_end - t_start))

  if echo "$result" | grep -q "succeeded"; then
    echo " ✅ 可连接 (${duration}ms)"
  elif echo "$result" | grep -q "refused"; then
    echo " ⚠️ 连接被拒绝（目标服务器拒绝）"
  elif echo "$result" | grep -q "timed out"; then
    echo " ❌ 超时（端口可能被封）"
  else
    echo " ❓ 未知状态：$result"
  fi
done

end_time=$(date +%s)
echo -e "\n✅ 检测完成，用时 $((end_time - start_time)) 秒"
echo "============================================"
