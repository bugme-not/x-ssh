#!/bin/bash
BOLD='\033[1m'; RESET='\033[0m'; NC='\033[0m'

CYAN='\033[1;36m'
GREEN='\033[1;32m'
MAGENTA='\033[1;35m'
PINK='\033[38;5;201m'
YELLOW='\033[1;33m'


BORDER_COLOR='[1;35m'

echo ""
echo -e "${BORDER_COLOR}# ==================================================${RESET}"
echo -e "${BORDER_COLOR}#${RESET}"
echo -e "${BORDER_COLOR}#${RESET} ${BOLD}${CYAN}WELCOME TO CXLVINVlSSH-WS DEPLOYER SCRIPT v2.6${RESET}"
echo -e "${BORDER_COLOR}#${RESET}"
echo -e "${BORDER_COLOR}# ==================================================${RESET}"
echo ""


PROJECT_ID=$(gcloud config get-value project 2>/dev/null | tr -d '[:space:]')
if [ -z "$PROJECT_ID" ]; then
    echo -e "  ${MAGENTA}ERROR: No active GCP project detected. Please run 'gcloud init'.${RESET}"
    exit 1
fi

echo -e "  ${CYAN}[+] ENABLING REQUIRED GCP APIS...${RESET}"
gcloud services enable cloudbuild.googleapis.com artifactregistry.googleapis.com run.googleapis.com --project="$PROJECT_ID" >/dev/null 2>&1

echo -e "  ${MAGENTA}==================================================${NC}"
echo -e "  ${GREEN}                 SERVICE NAME${NC}"
echo -e "  ${MAGENTA}==================================================${NC}"
echo -e "  ${YELLOW}Note: Use lowercase letters only. Do not use uppercase${NC}"
echo -e "  ${YELLOW}letters or the deployment will fail (e.g., ${GREEN}cxlvin ✔${YELLOW}, ${RED}Cxlvin ✘${YELLOW}).${NC}"
echo -e "  ${MAGENTA}--------------------------------------------------${NC}"
read -r -p "$(echo -e "  ${CYAN}SERVICE NAME [example: cxlvin]: ${RESET}")" INPUT_NAME
SERVICE_NAME=${INPUT_NAME:-cxlvin}
echo ""
echo -e "  ${MAGENTA}==================================================${NC}"
echo -e "  ${GREEN}              SELECT REGION${NC}"
echo -e "  ${MAGENTA}==================================================${NC}"
echo -e "  ${YELLOW}Note: Please select a region available in your lab.${NC}"
echo -e "  ${YELLOW}Selecting an unavailable region will cause the build to fail.${NC}"
echo -e "  ${MAGENTA}--------------------------------------------------${NC}"
echo -e "  ${YELLOW}--- NORTH AMERICA ---${RESET}"
echo -e "  ${CYAN}0. us-central1 (Iowa)${RESET}"
echo -e "  ${CYAN}1. us-east1 (South Carolina)${RESET}"
echo -e "  ${CYAN}2. us-east4 (N. Virginia)${RESET}"
echo -e "  ${CYAN}3. us-west1 (Oregon)${RESET}"
echo -e "  ${CYAN}4. us-west2 (Los Angeles)${RESET}"
echo -e "  ${YELLOW}--- EUROPE ---${RESET}"
echo -e "  ${CYAN}5. europe-west1 (Belgium)${RESET}"
echo -e "  ${CYAN}6. europe-west2 (London)${RESET}"
echo -e "  ${CYAN}7. europe-west3 (Frankfurt)${RESET}"
echo -e "  ${CYAN}8. europe-west4 (Eemshaven)${RESET}"
echo -e "  ${CYAN}9. europe-west6 (Zurich)${RESET}"
echo -e "  ${YELLOW}--- ASIA-PACIFIC ---${RESET}"
echo -e "  ${CYAN}10. asia-east1 (Taiwan)${RESET}"
echo -e "  ${CYAN}11. asia-east2 (Hong Kong)${RESET}"
echo -e "  ${CYAN}12. asia-northeast1 (Tokyo)${RESET}"
echo -e "  ${CYAN}13. asia-northeast2 (Osaka)${RESET}"
echo -e "  ${CYAN}14. asia-southeast1 (Singapore)${RESET}"
echo -e "  ${CYAN}15. asia-southeast2 (Jakarta)${RESET}"
echo -e "  ${CYAN}16. asia-south1 (Mumbai)${RESET}"
echo ""
read -r -p "$(echo -e "  ${GREEN}REGION CHOICE [0-16]: ${RESET}")" REGION_CHOICE
case "$REGION_CHOICE" in
    0) REGION="us-central1" ;;
    1) REGION="us-east1" ;;
    2) REGION="us-east4" ;;
    3) REGION="us-west1" ;;
    4) REGION="us-west2" ;;
    5) REGION="europe-west1" ;;
    6) REGION="europe-west2" ;;
    7) REGION="europe-west3" ;;
    8) REGION="europe-west4" ;;
    9) REGION="europe-west6" ;;
    10) REGION="asia-east1" ;;
    11) REGION="asia-east2" ;;
    12) REGION="asia-northeast1" ;;
    13) REGION="asia-northeast2" ;;
    14) REGION="asia-southeast1" ;;
    15) REGION="asia-southeast2" ;;
    16) REGION="asia-south1" ;;
    *) REGION="us-central1" ;;
esac
echo -e "  ${GREEN}SELECTED REGION: ${CYAN}${REGION}${RESET}"
echo ""
echo -e "  ${MAGENTA}==================================================${NC}"
echo -e "  ${GREEN}            BUILD MODE SELECTION${NC}"
echo -e "  ${MAGENTA}==================================================${NC}"
echo -e "  ${CYAN}1) ðŸš€ HIGH PERFORMANCE${RESET}"
echo -e "  ${GREEN}   Billing Type        : Instance-Based${RESET}"
echo -e "  ${GREEN}   vCPU                : 4CPU${RESET}"
echo -e "  ${GREEN}   Memory              : 4Gi${RESET}"
echo -e "  ${GREEN}   Concurrency         : 1000${RESET}"
echo -e "  ${GREEN}   Timeout             : 3600${RESET}"
echo -e "  ${GREEN}   Auto Scaling:${RESET}"
echo -e "  ${GREEN}     Min Instances       : 1${RESET}"
echo -e "  ${GREEN}     Max Instances       : 4${RESET}"
echo -e "  ${GREEN}   Revision Scaling:${RESET}"
echo -e "  ${GREEN}     Min Instances       : 1${RESET}"
echo -e "  ${GREEN}     Max Instances       : 4${RESET}"
echo -e "  ${GREEN}   Execution Env       : Gen2${RESET}"
echo -e "  ${GREEN}   CPU Boost           : Enabled${RESET}"
echo -e "  ${CYAN}2) ðŸŒ± ESSENTIAL${RESET}"
echo -e "  ${GREEN}   Billing Type        : Instance-Based${RESET}"
echo -e "  ${GREEN}   vCPU                : 1CPU${RESET}"
echo -e "  ${GREEN}   Memory              : 512Mi${RESET}"
echo -e "  ${GREEN}   Concurrency         : 1000${RESET}"
echo -e "  ${GREEN}   Timeout             : 3600${RESET}"
echo -e "  ${GREEN}   Auto Scaling:${RESET}"
echo -e "  ${GREEN}     Min Instances       : 1${RESET}"
echo -e "  ${GREEN}     Max Instances       : 2${RESET}"
echo -e "  ${GREEN}   Revision Scaling:${RESET}"
echo -e "  ${GREEN}     Min Instances       : 1${RESET}"
echo -e "  ${GREEN}     Max Instances       : 2${RESET}"
echo -e "  ${GREEN}   Execution Env       : Gen2${RESET}"
echo -e "  ${GREEN}   CPU Boost           : Enabled${RESET}"
echo -e "  ${CYAN}3) âš–ï¸ STANDARD${RESET}"
echo -e "  ${GREEN}   Billing Type        : Instance-Based${RESET}"
echo -e "  ${GREEN}   vCPU                : 1CPU${RESET}"
echo -e "  ${GREEN}   Memory              : 1Gi${RESET}"
echo -e "  ${GREEN}   Concurrency         : 1000${RESET}"
echo -e "  ${GREEN}   Timeout             : 3600${RESET}"
echo -e "  ${GREEN}   Auto Scaling:${RESET}"
echo -e "  ${GREEN}     Min Instances       : 1${RESET}"
echo -e "  ${GREEN}     Max Instances       : 2${RESET}"
echo -e "  ${GREEN}   Revision Scaling:${RESET}"
echo -e "  ${GREEN}     Min Instances       : 1${RESET}"
echo -e "  ${GREEN}     Max Instances       : 2${RESET}"
echo -e "  ${GREEN}   Execution Env       : Gen2${RESET}"
echo -e "  ${GREEN}   CPU Boost           : Enabled${RESET}"
echo -e "  ${CYAN}4) âš¡ BALANCED${RESET}"
echo -e "  ${GREEN}   Billing Type        : Instance-Based${RESET}"
echo -e "  ${GREEN}   vCPU                : 2CPU${RESET}"
echo -e "  ${GREEN}   Memory              : 2Gi${RESET}"
echo -e "  ${GREEN}   Concurrency         : 1000${RESET}"
echo -e "  ${GREEN}   Timeout             : 3600${RESET}"
echo -e "  ${GREEN}   Auto Scaling:${RESET}"
echo -e "  ${GREEN}     Min Instances       : 1${RESET}"
echo -e "  ${GREEN}     Max Instances       : 2${RESET}"
echo -e "  ${GREEN}   Revision Scaling:${RESET}"
echo -e "  ${GREEN}     Min Instances       : 1${RESET}"
echo -e "  ${GREEN}     Max Instances       : 2${RESET}"
echo -e "  ${GREEN}   Execution Env       : Gen2${RESET}"
echo -e "  ${GREEN}   CPU Boost           : Enabled${RESET}"
echo ""
read -r -p "$(echo -e "  ${CYAN}CHOICE [1-4]: ${RESET}")" MODE_CHOICE
case "$MODE_CHOICE" in
    1) CPU="4"; RAM="4Gi"; MODE="1) ðŸš€ HIGH PERFORMANCE"; MIN_INSTANCES="1"; MAX_INSTANCES="4" ;;
    2) CPU="1"; RAM="512Mi"; MODE="2) ðŸŒ± ESSENTIAL"; MIN_INSTANCES="1"; MAX_INSTANCES="2" ;;
    3) CPU="1"; RAM="1Gi"; MODE="3) âš–ï¸ STANDARD"; MIN_INSTANCES="1"; MAX_INSTANCES="2" ;;
    4) CPU="2"; RAM="2Gi"; MODE="4) âš¡ BALANCED"; MIN_INSTANCES="1"; MAX_INSTANCES="2" ;;
    *) CPU="2"; RAM="2Gi"; MODE="4) âš¡ BALANCED"; MIN_INSTANCES="1"; MAX_INSTANCES="2" ;;
esac

echo -e "  ${GREEN}SELECTED MODE: ${CYAN}${MODE} (${CPU} vCPU / ${RAM})${RESET}"
echo ""

echo -e "  ${PINK}[+] GENERATING DEPLOYMENT FILES...${RESET}"

# --- 1. banner.txt ---
cat << 'EOF' > banner.txt
<font color="#00ffff">======================================</font>
<font color="#ff0000">Cxlvin</font><font color="#ffcaa1">Vl</font><font color="#ffff00">SSH</font><font color="#ffffff">: </font><font color="#00ff00">BUILT_WITH_INTENT </font>ðŸ«ªðŸ–•ðŸ»
<font color="#00ffff">======================================</font>
EOF

# --- 2. Xray Config ---
cat << 'EOF' > xray_config.json
{
  "log": {
    "loglevel": "none"
  },
  "inbounds": [
    {
      "port": 10085,
      "listen": "127.0.0.1",
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "cxlvin777",
            "level": 0
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/CxlvinVlWS",
          "maxEarlyData": 2048,
          "earlyDataHeaderName": "Sec-WebSocket-Protocol"
        },
        "sockopt": {
          "tcpFastOpen": true,
          "tcpNoDelay": true,
          "mark": 255
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "tag": "direct",
      "settings": {
        "domainStrategy": "UseIP"
      },
      "streamSettings": {
        "sockopt": {
          "tcpFastOpen": true,
          "tcpNoDelay": true
        }
      }
    }
  ]
}
EOF

# --- 3. Anti-DDoS Module (anti_ddos.py) ---
cat << 'EOF' > anti_ddos.py
import asyncio
import collections
import socket
import struct
import time
import os
import sys

try:
    import uvloop
    uvloop.install()
except ImportError:
    pass

MAX_CONN_PER_IP = 150       
RATE_LIMIT_WINDOW = 5       
MAX_REQ_PER_WINDOW = 200    
BAN_TIME = 600              
IPSET_NAME = "antiddos_blacklist"
LOOP_INTERVAL = 0.5         

banned_ips = {}  
ip_history = collections.defaultdict(lambda: collections.deque(maxlen=MAX_REQ_PER_WINDOW + 10))

IPV4_PACK = struct.Struct("<I")
IPV6_PACK = struct.Struct("<4I")

ipset_proc = None

def log(msg: str) -> None:
    print(f"[Anti-DDoS Engine] {time.strftime('%Y-%m-%d %H:%M:%S')} - {msg}", flush=True)

def parse_hex_ip_fast(hex_str: str) -> str:
    try:
        length = len(hex_str)
        if length == 8:
            addr_int = int(hex_str, 16)
            return socket.inet_ntop(socket.AF_INET, IPV4_PACK.pack(addr_int))
        elif length == 32:
            words = (
                int(hex_str[0:8], 16),
                int(hex_str[8:16], 16),
                int(hex_str[16:24], 16),
                int(hex_str[24:32], 16)
            )
            return socket.inet_ntop(socket.AF_INET6, IPV6_PACK.pack(*words))
    except (ValueError, OSError):
        pass
    return ""

def read_proc_sockets_fast():
    remote_ips = []
    
    for path in ("/proc/net/tcp", "/proc/net/tcp6"):
        if not os.path.exists(path):
            continue
            
        with open(path, "rb") as f:
            f.readline()
            for line in f:
                parts = line.split()
                if len(parts) < 4:
                    continue
                
                state = parts[3]
                if state != b"01" and state != b"02":
                    continue
                
                rem_addr = parts[2]
                colon_pos = rem_addr.find(b":")
                if colon_pos == -1:
                    continue
                
                hex_ip = rem_addr[:colon_pos].decode("ascii")
                ip = parse_hex_ip_fast(hex_ip)
                
                if ip and not (ip.startswith("127.") or ip == "::1" or ip == "0.0.0.0"):
                    remote_ips.append(ip)
                    
    return remote_ips

async def exec_cmd(*args) -> bool:
    proc = await asyncio.create_subprocess_exec(
        *args, stdout=asyncio.subprocess.DEVNULL, stderr=asyncio.subprocess.DEVNULL
    )
    await proc.wait()
    return proc.returncode == 0

async def setup_firewall():
    global ipset_proc
    log("Initializing kernel ipset rules...")
    await exec_cmd("ipset", "create", IPSET_NAME, "hash:ip", "timeout", str(BAN_TIME), "-exist")
    await exec_cmd("iptables", "-I", "INPUT", "-m", "set", "--match-set", IPSET_NAME, "src", "-j", "DROP")
    
    ipset_proc = await asyncio.create_subprocess_exec(
        "ipset", "restore",
        stdin=asyncio.subprocess.PIPE,
        stdout=asyncio.subprocess.DEVNULL,
        stderr=asyncio.subprocess.DEVNULL
    )

async def ban_ips_batch(ips: list):
    if not ips or not ipset_proc or ipset_proc.stdin.is_closing():
        return

    now = time.time()
    commands = []
    
    for ip in ips:
        if ip in banned_ips:
            continue
        banned_ips[ip] = now + BAN_TIME
        commands.append(f"add {IPSET_NAME} {ip} timeout {BAN_TIME} -exist\n")
        log(f"ALERT: Ban applied to {ip} (Kernel ipset)")
        
    if commands:
        payload = "".encode("utf-8").join(c.encode("utf-8") for c in commands)
        ipset_proc.stdin.write(payload)
        await ipset_proc.stdin.drain()

async def prune_expired_bans():
    now = time.time()
    expired = [ip for ip, exp_time in banned_ips.items() if now >= exp_time]
    for ip in expired:
        del banned_ips[ip]
        ip_history.pop(ip, None)

async def inspect_connections():
    now = time.time()
    remote_ips = await asyncio.to_thread(read_proc_sockets_fast)
    
    active_counts = collections.defaultdict(int)
    ips_to_ban = set()

    for ip in remote_ips:
        if ip in banned_ips:
            continue

        active_counts[ip] += 1
        history = ip_history[ip]
        history.append(now)

        if active_counts[ip] > MAX_CONN_PER_IP:
            log(f"EXCEEDED CONCURRENCY: {ip} ({active_counts[ip]} active sockets)")
            ips_to_ban.add(ip)
            continue

        while history and now - history[0] > RATE_LIMIT_WINDOW:
            history.popleft()

        if len(history) > MAX_REQ_PER_WINDOW:
            log(f"RATE LIMIT EXCEEDED: {ip} ({len(history)} reqs/{RATE_LIMIT_WINDOW}s)")
            ips_to_ban.add(ip)

    if ips_to_ban:
        await ban_ips_batch(list(ips_to_ban))

async def main():
    await setup_firewall()
    log("Engine started. Real-time C-level kernel socket inspection active...")

    while True:
        try:
            await inspect_connections()
            await prune_expired_bans()
        except Exception as e:
            log(f"Error inside engine loop: {e}")
            
        await asyncio.sleep(LOOP_INTERVAL)

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        if ipset_proc:
            ipset_proc.terminate()
        log("Shutting down engine...")
        
EOF

# --- 4. Log Cleaner Module (log_cleaner.py) ---
cat << 'EOF' > log_cleaner.py
import asyncio
import os
import time
import glob

try:
    import uvloop
    uvloop.install()
except ImportError:
    pass

LOG_PATHS = [
    "/var/log/nginx/*.log",
    "/var/log/sshd.log",
    "/var/log/syslog",
    "/var/log/messages",
    "/var/log/auth.log",
    "/tmp/*.log"
]

# Targeted directories (avoiding sweeping root /tmp wipes)
DIRS_TO_PURGE = ["/var/tmp", "/var/cache/nginx"]
CLEAN_INTERVAL = 120
MAX_FILE_SIZE_BYTES = 10 * 1024 * 1024
TEMP_MAX_AGE_SEC = 300

def log(msg: str) -> None:
    print(f"[Log-Cleaner] {time.strftime('%Y-%m-%d %H:%M:%S')} - {msg}", flush=True)

def truncate_file(filepath: str) -> None:
    """Uses non-blocking POSIX system calls directly."""
    try:
        fd = os.open(filepath, os.O_RDWR | os.O_NONBLOCK)
        try:
            os.ftruncate(fd, 0)
            log(f"Truncated oversized log: {filepath}")
        finally:
            os.close(fd)
    except Exception:
        pass

def scan_and_filter_logs(pattern: str) -> list[str]:
    targets = []
    for filepath in glob.glob(pattern):
        try:
            if os.path.isfile(filepath) and os.path.getsize(filepath) > MAX_FILE_SIZE_BYTES:
                targets.append(filepath)
        except Exception:
            pass
    return targets

async def purge_logs():
    loop = asyncio.get_running_loop()
    scan_tasks = [loop.run_in_executor(None, scan_and_filter_logs, pattern) for pattern in LOG_PATHS]
    results = await asyncio.gather(*scan_tasks)
    
    truncation_tasks = []
    for oversized_files in results:
        for filepath in oversized_files:
            truncation_tasks.append(loop.run_in_executor(None, truncate_file, filepath))
            
    if truncation_tasks:
        await asyncio.gather(*truncation_tasks)

def _scan_directory_fast(path_str: str) -> list[str]:
    now = time.time()
    files_to_remove = []
    if not os.path.exists(path_str):
        return files_to_remove
    try:
        with os.scandir(path_str) as entries:
            for entry in entries:
                try:
                    if entry.is_file(follow_symlinks=False) and not entry.name.endswith('.py'):
                        stat = entry.stat(follow_symlinks=False)
                        if now - stat.st_mtime > TEMP_MAX_AGE_SEC:
                            files_to_remove.append(entry.path)
                except Exception:
                    pass
    except Exception:
        pass
    return files_to_remove

def unlink_file(filepath: str) -> None:
    try:
        os.unlink(filepath)
    except Exception:
        pass

async def wipe_temp_cache():
    loop = asyncio.get_running_loop()
    scan_tasks = [loop.run_in_executor(None, _scan_directory_fast, d) for d in DIRS_TO_PURGE]
    results = await asyncio.gather(*scan_tasks)
    
    removal_tasks = []
    for file_list in results:
        for filepath in file_list:
            removal_tasks.append(loop.run_in_executor(None, unlink_file, filepath))
            
    if removal_tasks:
        await asyncio.gather(*removal_tasks)

async def main():
    log("Engine active. Fast async log sanitization enabled...")
    while True:
        try:
            await asyncio.gather(purge_logs(), wipe_temp_cache())
        except Exception as e:
            log(f"Cycle execution error: {e}")
        await asyncio.sleep(CLEAN_INTERVAL)

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        log("Shutting down engine...")
        
EOF

# --- 5. entrypoint.sh ---
cat << 'EOF' > entrypoint.sh
#!/bin/bash
set -e

echo "[+] Starting initialization script..."

# 1. File Descriptor Limits
ulimit -n 65535 2>/dev/null || true

# 2. Kernel & TCP Parameters Tuning
echo "[+] Attempting Kernel & TCP Socket Tuning..."
sysctl -w net.core.default_qdisc=fq 2>/dev/null || true
sysctl -w net.ipv4.tcp_congestion_control=bbr 2>/dev/null || true

sysctl -w net.core.rmem_max=16777216 2>/dev/null || true
sysctl -w net.core.wmem_max=16777216 2>/dev/null || true
sysctl -w net.ipv4.tcp_rmem="4096 87380 16777216" 2>/dev/null || true
sysctl -w net.ipv4.tcp_wmem="4096 65536 16777216" 2>/dev/null || true

sysctl -w net.ipv4.tcp_fin_timeout=15 2>/dev/null || true
sysctl -w net.ipv4.tcp_tw_reuse=1 2>/dev/null || true
sysctl -w net.ipv4.tcp_fastopen=3 2>/dev/null || true

echo "[+] Generating SSH Host Keys..."
ssh-keygen -A
mkdir -p /run/sshd /var/run/sshd

echo "[+] Starting Custom SSH Daemon..."
/usr/sbin/sshd

echo "[+] Starting Anti-DDoS Engine..."
python3 /usr/local/bin/anti_ddos.py &
ANTIDDOS_PID=$!

echo "[+] Starting Log Cleaner Daemon..."
python3 /usr/local/bin/log_cleaner.py &
CLEANER_PID=$!

echo "[+] Starting Xray Core..."
xray run -config /usr/local/etc/xray/config.json &
XRAY_PID=$!

echo "[+] Starting BadVPN UDPGW..."
badvpn-udpgw \
  --listen-addr 127.0.0.1:7300 \
  --max-clients 1000 \
  --max-connections-for-client 40 \
  --loglevel warning &
UDPGW_PID=$!

echo "[+] Creating Optimized WS-to-TCP Bridge..."
cat << 'PYEOF' > /tmp/bridge.py
import socket, threading

BUF_SIZE = 65536

def tune_socket(sock):
    sock.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
    try:
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, 1 << 20)
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_SNDBUF, 1 << 20)
    except OSError:
        pass

def bridge(src, dst):
    try:
        while True:
            data = src.recv(BUF_SIZE)
            if not data:
                break
            dst.sendall(data)
    except Exception:
        pass
    finally:
        src.close()
        dst.close()

def handle(client):
    try:
        tune_socket(client)
        client.recv(4096)
        client.sendall(b"HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\n\r\n")
        ssh = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        tune_socket(ssh)
        ssh.connect(('127.0.0.1', 22))
        threading.Thread(target=bridge, args=(client, ssh), daemon=True).start()
        threading.Thread(target=bridge, args=(ssh, client), daemon=True).start()
    except Exception:
        client.close()

server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
server.bind(('127.0.0.1', 2222))
server.listen(200)
while True:
    client, _ = server.accept()
    threading.Thread(target=handle, args=(client,), daemon=True).start()
PYEOF

python3 /tmp/bridge.py &
BRIDGE_PID=$!

echo "[+] Starting Watchdog Monitor..."
(
  while true; do
    sleep 10
    if ! kill -0 "$ANTIDDOS_PID" 2>/dev/null; then
      python3 /usr/local/bin/anti_ddos.py &
      ANTIDDOS_PID=$!
    fi
    if ! kill -0 "$CLEANER_PID" 2>/dev/null; then
      python3 /usr/local/bin/log_cleaner.py &
      CLEANER_PID=$!
    fi
    if ! kill -0 "$UDPGW_PID" 2>/dev/null; then
      badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 1000 \
        --max-connections-for-client 40 --loglevel warning &
      UDPGW_PID=$!
    fi
    if ! kill -0 "$BRIDGE_PID" 2>/dev/null; then
      python3 /tmp/bridge.py &
      BRIDGE_PID=$!
    fi
    if ! kill -0 "$XRAY_PID" 2>/dev/null; then
      xray run -config /usr/local/etc/xray/config.json &
      XRAY_PID=$!
    fi
    if ! pgrep -x sshd > /dev/null; then
      /usr/sbin/sshd
    fi
  done
) &

echo "[+] Starting Nginx..."
exec nginx -g "daemon off;"
EOF
chmod +x entrypoint.sh

# --- 6. nginx.conf ---
cat << 'EOF' > nginx.conf
worker_processes auto;
events {
    worker_connections 8192;
    multi_accept on;
    use epoll;
}
http {
    client_header_buffer_size 8k;
    large_client_header_buffers 4 32k;
    tcp_nodelay on;
    tcp_nopush off;
    sendfile off;
    keepalive_timeout 3600;

    map $http_sec_websocket_key $ws_key {
        default $http_sec_websocket_key;
        ""      "Y7bV4mQ9X1pK3zT8wL5nR2==";
    }

    map $http_sec_websocket_version $ws_version {
        default $http_sec_websocket_version;
        ""      "13";
    }

    map $http_upgrade $connection_upgrade {
        default upgrade;
        '' close;
    }

    server {
        listen 8080;
        server_name _;

        location /cxlvin {
            proxy_pass http://127.0.0.1:2222;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $connection_upgrade;
            proxy_set_header Sec-WebSocket-Key $ws_key;
            proxy_set_header Sec-WebSocket-Version $ws_version;
            proxy_set_header Host $host;
            proxy_read_timeout 86400s;
            proxy_send_timeout 86400s;
            proxy_buffering off;
            proxy_request_buffering off;
            proxy_socket_keepalive on;
        }

        location /CxlvinVlWS {
            proxy_redirect off;
            proxy_pass http://127.0.0.1:10085;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_read_timeout 86400s;
            proxy_send_timeout 86400s;
        }

        location / {
            return 302 https://m.youtube.com/watch?v=dQw4w9WgXcQ;
        }
    }
}
EOF

# --- 7. Dockerfile ---
cat << 'EOF' > Dockerfile
FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential libssl-dev zlib1g-dev libpam0g-dev libselinux1-dev \
    nginx python3 cmake git wget curl ca-certificates unzip iproute2 iptables \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN useradd -r -s /bin/false sshd || true

# Patch version.h directly and compile OpenSSH from source with exact custom identity
RUN wget --no-check-certificate -O /tmp/openssh.tar.gz https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-9.8p1.tar.gz \
    && tar -xzf /tmp/openssh.tar.gz -C /tmp \
    && cd /tmp/openssh-9.8p1 \
    && sed -i 's/#define SSH_VERSION.*/#define SSH_VERSION "Tectia-SSH_9.5_NVIDIA-RTX-PRO-6000-Blackwell"/' version.h \
    && ./configure --prefix=/usr --sysconfdir=/etc/ssh --with-pam --with-ssl-dir=/usr \
    && make -j$(nproc) \
    && make install \
    && rm -rf /tmp/openssh*

# Direct Xray Core installation
RUN XRAY_VER=$(curl -s https://api.github.com/repos/XTLS/Xray-core/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') \
    && wget -O /tmp/xray.zip "https://github.com/XTLS/Xray-core/releases/download/${XRAY_VER}/Xray-linux-64.zip" \
    && unzip /tmp/xray.zip -d /usr/local/bin/ \
    && chmod +x /usr/local/bin/xray \
    && mkdir -p /usr/local/etc/xray \
    && rm -f /tmp/xray.zip

# Build BadVPN UDPGW
RUN git clone https://github.com/ambrop72/badvpn.git /tmp/badvpn \
    && cd /tmp/badvpn && mkdir build && cd build \
    && cmake .. -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1 \
    && make install && rm -rf /tmp/badvpn

RUN mkdir -p /var/run/sshd /run/sshd
RUN useradd -m -s /bin/bash cxlvin && echo 'cxlvin:cxlvin' | chpasswd

# Configure OpenSSH settings
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
RUN echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
RUN { \
    echo "UseDNS no"; \
    echo "TCPKeepAlive yes"; \
    echo "ClientAliveInterval 15"; \
    echo "ClientAliveCountMax 3"; \
    echo "MaxSessions 50"; \
    echo "MaxStartups 50:30:100"; \
    echo "Compression no"; \
    } >> /etc/ssh/sshd_config

COPY banner.txt /etc/ssh/banner.txt
RUN echo "Banner /etc/ssh/banner.txt" >> /etc/ssh/sshd_config

COPY anti_ddos.py /usr/local/bin/anti_ddos.py
COPY log_cleaner.py /usr/local/bin/log_cleaner.py
COPY xray_config.json /usr/local/etc/xray/config.json
COPY nginx.conf /etc/nginx/nginx.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh /usr/local/bin/anti_ddos.py /usr/local/bin/log_cleaner.py

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
EOF

echo -e "  ${CYAN}BUILDING CONTAINER IMAGE...${RESET}"
gcloud builds submit --tag "gcr.io/${PROJECT_ID}/${SERVICE_NAME}" --project="$PROJECT_ID"
if [ $? -ne 0 ]; then
    echo -e "  ${MAGENTA}BUILD FAILED.${RESET}"
    exit 1
fi

deploy_attempt() {
    local cpu="$1" mem="$2" mini="$3" maxi="$4"
    
    gcloud run deploy "$SERVICE_NAME" \
        --image "gcr.io/${PROJECT_ID}/${SERVICE_NAME}" \
        --platform managed --region "$REGION" \
        --port 8080 --allow-unauthenticated --project="$PROJECT_ID" \
        --cpu "$cpu" --memory "$mem" --min-instances "$mini" --max-instances "$maxi" \
        --concurrency 1000 --timeout 3600 --no-cpu-throttling --cpu-boost \
        --session-affinity --execution-environment gen2
}

echo -e "  ${CYAN}DEPLOYING SSH & VLESS SERVER HOST TO ${REGION}...${RESET}"
if deploy_attempt "$CPU" "$RAM" "$MIN_INSTANCES" "$MAX_INSTANCES"; then
    FINAL_CPU="$CPU"; FINAL_RAM="$RAM"; FINAL_MIN="$MIN_INSTANCES"; FINAL_MAX="$MAX_INSTANCES"; FINAL_MODE="$MODE"
elif deploy_attempt 2 2Gi 1 2; then
    FINAL_CPU="2"; FINAL_RAM="2Gi"; FINAL_MIN="1"; FINAL_MAX="2"; FINAL_MODE="4) âš¡ BALANCED (FALLBACK)"
elif deploy_attempt 1 512Mi 1 2; then
    FINAL_CPU="1"; FINAL_RAM="512Mi"; FINAL_MIN="1"; FINAL_MAX="2"; FINAL_MODE="2) ðŸŒ± ESSENTIAL (FALLBACK)"
else
    echo -e "  ${MAGENTA}ALL DEPLOY ATTEMPTS FAILED.${RESET}"
    echo -e "  ${CYAN}Check your actual quota at:${RESET}"
    echo -e "  https://console.cloud.google.com/iam-admin/quotas?project=${PROJECT_ID}"
    exit 1
fi

SERVICE_URL=$(gcloud run services describe "$SERVICE_NAME" --region "$REGION" --project="$PROJECT_ID" --format='value(status.url)' 2>/dev/null)
CLEAN_HOST=$(echo "$SERVICE_URL" | sed 's|https://||')

echo ""
echo -e "  ${GREEN} [âœ“] SSH & VLESS WEBSOCKET DEPLOYED SUCCESSFUL${RESET}"
echo ""
echo -e "  ${CYAN}SERVICE NAME     : ${GREEN}${SERVICE_NAME}${RESET}"
echo -e "  ${CYAN}RAW HOST         : ${GREEN}${CLEAN_HOST}${RESET}"
echo -e "  ${CYAN}SERVER HOST      : ${GREEN}${SERVICE_URL}${RESET}"
echo -e "  ${MAGENTA}--------------------------------------------------${NC}"
echo -e "  ${CYAN}SSH WS DETAILS:${RESET}"
echo -e "  ${CYAN}Username         : ${GREEN}cxlvin${RESET}"
echo -e "  ${CYAN}Password         : ${GREEN}cxlvin${RESET}"
echo -e "  ${CYAN}Port             : ${GREEN}443${RESET}"
echo -e "  ${CYAN}Payload          : ${GREEN}GET /cxlvin HTTP/1.1[crlf]Host: ${CLEAN_HOST}[crlf]Upgrade: websocket[crlf]Connection: Upgrade[crlf][crlf]${RESET}"
echo -e "  ${MAGENTA}--------------------------------------------------${NC}"
echo -e "  ${CYAN}VLESS WS DETAILS:${RESET}"
echo -e "  ${CYAN}UUID             : ${GREEN}cxlvin777${RESET}"
echo -e "  ${CYAN}Path             : ${GREEN}/CxlvinVlWS${RESET}"
echo -e "  ${MAGENTA}==================================================${NC}"
echo -e "  ${CYAN}  ${FINAL_MODE}${RESET}"
echo -e "  ${GREEN}   Billing Type        : Instance-Based${RESET}"
echo -e "  ${GREEN}   vCPU                : ${FINAL_CPU}CPU${RESET}"
echo -e "  ${GREEN}   Memory              : ${FINAL_RAM}${RESET}"
echo -e "  ${GREEN}   Concurrency         : 1000${RESET}"
echo -e "  ${GREEN}   Timeout             : 3600${RESET}"
echo -e "  ${GREEN}   Auto Scaling:${RESET}"
echo -e "  ${GREEN}     Min Instances       : ${FINAL_MIN}${RESET}"
echo -e "  ${GREEN}     Max Instances       : ${FINAL_MAX}${RESET}"
echo -e "  ${GREEN}   Revision Scaling:${RESET}"
echo -e "  ${GREEN}     Min Instances       : ${FINAL_MIN}${RESET}"
echo -e "  ${GREEN}     Max Instances       : ${FINAL_MAX}${RESET}"
echo -e "  ${GREEN}   Execution Env       : Gen2${RESET}"
echo -e "  ${GREEN}   CPU Boost           : Enabled${RESET}"
echo -e "  ${MAGENTA}==================================================${NC}"
echo ""


cleanup() {
    echo -e "\n  ${PINK}CLEANING UP LOCAL BUILD LOGS AND GENERATED FILES...${RESET}"
    rm -f banner.txt entrypoint.sh nginx.conf Dockerfile xray_config.json anti_ddos.py log_cleaner.py
    echo -e "  ${CYAN}DEPLOYER SESSION CLOSED.${RESET}\n"
}

cleanup
