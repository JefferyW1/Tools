#!/usr/bin/env sh
set -eu

# Linux-only tuning for high-throughput HAProxy TCP forwarding.
# It does not edit HAProxy configuration.

SYSCTL_FILE="/etc/sysctl.d/99-haproxy-tcp-forwarding.conf"
LIMITS_FILE="/etc/security/limits.d/99-haproxy-tcp-forwarding.conf"
SYSTEMD_DIR="/etc/systemd/system.conf.d"
SYSTEMD_FILE="${SYSTEMD_DIR}/99-haproxy-tcp-forwarding.conf"
MODULES_FILE="/etc/modules-load.d/99-haproxy-tcp-forwarding.conf"

if [ "$(id -u)" -ne 0 ]; then
  echo "Run as root, for example: sudo sh $0" >&2
  exit 1
fi

backup_file() {
  file="$1"
  if [ -f "$file" ] && [ ! -f "${file}.bak" ]; then
    cp "$file" "${file}.bak"
  fi
}

cpu_count() {
  n="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)"
  case "$n" in
    ''|*[!0-9]*) echo 1 ;;
    *) echo "$n" ;;
  esac
}

apply_qdisc_and_bbr() {
  if [ -r /proc/sys/net/ipv4/tcp_available_congestion_control ] &&
     grep -qw bbr /proc/sys/net/ipv4/tcp_available_congestion_control; then
    sysctl -w net.ipv4.tcp_congestion_control=bbr >/dev/null || true
  fi

  if [ -r /proc/sys/net/core/default_qdisc ]; then
    sysctl -w net.core.default_qdisc=fq >/dev/null || true
  fi
}

enable_rps() {
  cpus="$(cpu_count)"
  if [ "$cpus" -le 1 ]; then
    return 0
  fi

  if command -v python3 >/dev/null 2>&1; then
    mask="$(python3 - "$cpus" <<'PY'
import sys
n = int(sys.argv[1])
print(hex((1 << n) - 1)[2:])
PY
)"
  else
    # Fallback for up to 32 CPUs.
    mask="ffffffff"
  fi

  for queue in /sys/class/net/*/queues/rx-*; do
    [ -w "$queue/rps_cpus" ] || continue
    case "$queue" in
      */lo/*) continue ;;
    esac
    echo "$mask" > "$queue/rps_cpus" || true
  done

  if [ -w /proc/sys/net/core/rps_sock_flow_entries ]; then
    sysctl -w net.core.rps_sock_flow_entries=32768 >/dev/null || true
  fi

  for queue in /sys/class/net/*/queues/rx-*; do
    [ -w "$queue/rps_flow_cnt" ] || continue
    case "$queue" in
      */lo/*) continue ;;
    esac
    echo 4096 > "$queue/rps_flow_cnt" || true
  done
}

set_cpu_governor_performance() {
  for gov in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    [ -w "$gov" ] || continue
    echo performance > "$gov" || true
  done
}

mkdir -p "$(dirname "$SYSCTL_FILE")" "$SYSTEMD_DIR" "$(dirname "$LIMITS_FILE")" "$(dirname "$MODULES_FILE")"
backup_file "$SYSCTL_FILE"
backup_file "$LIMITS_FILE"
backup_file "$SYSTEMD_FILE"
backup_file "$MODULES_FILE"

cat > "$MODULES_FILE" <<'EOF'
tcp_bbr
EOF

modprobe tcp_bbr 2>/dev/null || true

cat > "$SYSCTL_FILE" <<'EOF'
# High-throughput TCP proxy host tuning.
# Safe to re-apply with: sysctl --system

# Larger listen and packet queues reduce drops during bursts.
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 250000
net.ipv4.tcp_max_syn_backlog = 65535

# Larger socket buffers help long-distance TCP flows, common with cloud proxying.
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.core.rmem_default = 1048576
net.core.wmem_default = 1048576
net.ipv4.tcp_rmem = 4096 87380 134217728
net.ipv4.tcp_wmem = 4096 65536 134217728
net.ipv4.tcp_mtu_probing = 1

# HAProxy opens outbound connections to the target side; give it more ephemeral ports.
net.ipv4.ip_local_port_range = 1024 65535

# Recycle dead TCP state faster while keeping sane FIN behavior.
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_max_tw_buckets = 2000000

# Keep idle TCP sessions detectable without being overly aggressive.
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_keepalive_intvl = 30
net.ipv4.tcp_keepalive_probes = 5

# Avoid swapping a busy proxy process.
vm.swappiness = 1

# Raise kernel-wide file descriptor capacity.
fs.file-max = 2097152
fs.nr_open = 2097152
EOF

if [ -r /proc/sys/net/ipv4/tcp_available_congestion_control ] &&
   grep -qw bbr /proc/sys/net/ipv4/tcp_available_congestion_control; then
  cat >> "$SYSCTL_FILE" <<'EOF'

# Modern congestion control and queueing.
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
EOF
else
  cat >> "$SYSCTL_FILE" <<'EOF'

# Fair queueing is useful even when BBR is unavailable.
net.core.default_qdisc = fq
EOF
fi

if [ -e /proc/sys/net/netfilter/nf_conntrack_max ]; then
  cat >> "$SYSCTL_FILE" <<'EOF'

# If conntrack is loaded by firewall/NAT rules, avoid table exhaustion.
net.netfilter.nf_conntrack_max = 1048576
net.netfilter.nf_conntrack_tcp_timeout_established = 86400
EOF
fi

sysctl --system || true
apply_qdisc_and_bbr

cat > "$LIMITS_FILE" <<'EOF'
* soft nofile 1048576
* hard nofile 1048576
root soft nofile 1048576
root hard nofile 1048576
EOF

cat > "$SYSTEMD_FILE" <<'EOF'
[Manager]
DefaultLimitNOFILE=1048576
DefaultLimitNPROC=1048576
DefaultTasksMax=infinity
EOF

systemctl daemon-reexec 2>/dev/null || true

set_cpu_governor_performance
enable_rps

echo
echo "Linux TCP forwarding host tuning has been applied."
echo "Persistent files written:"
echo "  $SYSCTL_FILE"
echo "  $LIMITS_FILE"
echo "  $SYSTEMD_FILE"
echo "  $MODULES_FILE"
echo
echo "Recommended next steps:"
echo "  1. Reboot once so systemd limits and tcp_bbr module loading are cleanly applied."
echo "  2. After reboot, verify with:"
echo "     sysctl net.ipv4.tcp_congestion_control net.core.default_qdisc fs.file-max"
echo "     ulimit -n"
echo "  3. Restart HAProxy after reboot so it inherits the new systemd limits."
