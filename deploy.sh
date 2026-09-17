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
read -r -p "$(echo -e "  ${CYAN}SERVICE NAME [cxlvin]: ${RESET}")" INPUT_NAME
SERVICE_NAME=${INPUT_NAME:-example:cxlvin}
echo ""

echo -e "  ${MAGENTA}==================================================${NC}"
echo -e "  ${GREEN}              SELECT REGION${NC}"
echo -e "  ${MAGENTA}==================================================${NC}"
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
echo -e "  ${CYAN}1) 🚀 HIGH PERFORMANCE${RESET}"
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
echo -e "  ${CYAN}2) 🌱 ESSENTIAL${RESET}"
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
echo -e "  ${CYAN}3) ⚖️ STANDARD${RESET}"
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
echo -e "  ${CYAN}4) ⚡ BALANCED${RESET}"
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
    1) CPU="4"; RAM="4Gi"; MODE="1) 🚀 HIGH PERFORMANCE"; MIN_INSTANCES="1"; MAX_INSTANCES="4" ;;
    2) CPU="1"; RAM="512Mi"; MODE="2) 🌱 ESSENTIAL"; MIN_INSTANCES="1"; MAX_INSTANCES="2" ;;
    3) CPU="1"; RAM="1Gi"; MODE="3) ⚖️ STANDARD"; MIN_INSTANCES="1"; MAX_INSTANCES="2" ;;
    4) CPU="2"; RAM="2Gi"; MODE="4) ⚡ BALANCED"; MIN_INSTANCES="1"; MAX_INSTANCES="2" ;;
    *) CPU="2"; RAM="2Gi"; MODE="4) ⚡ BALANCED"; MIN_INSTANCES="1"; MAX_INSTANCES="2" ;;
esac

echo -e "  ${GREEN}SELECTED MODE: ${CYAN}${MODE} (${CPU} vCPU / ${RAM})${RESET}"
echo ""

echo -e "  ${PINK}[+] GENERATING DEPLOYMENT FILES...${RESET}"

# --- 1. banner.txt ---
cat << 'EOF' > banner.txt
<font color="#00ffff">======================================</font>
<font color="#ff0000">Cxlvin</font><font color="#ffcaa1">Vl</font><font color="#ffff00">SSH</font><font color="#ffffff">: </font><font color="#00ff00">BUILT_WITH_INTENT </font>🫪🖕🏻
<font color="#00ffff">======================================</font>
EOF

# --- 2. Xray Config ---
cat << 'EOF' > xray_config.json
{
  "log": {
    "loglevel": "warning"
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
          "path": "/CxlvinVlWS"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom"
    }
  ]
}
EOF

# --- 3. Anti-DDoS Module (anti_ddos.py) ---
cat << 'EOF' > anti_ddos.py
import time
import subprocess
import collections
import os
import sys

# Configuration Parameters
MAX_CONN_PER_IP = 150       # Maximum concurrent sockets per remote IP
RATE_LIMIT_WINDOW = 5       # Window in seconds
MAX_REQ_PER_WINDOW = 200    # Threshold connections within window
BAN_TIME = 600              # Ban duration in seconds (10 mins)

banned_ips = {}
ip_history = collections.defaultdict(list)

def log(msg):
    print(f"[Anti-DDoS] {time.strftime('%Y-%m-%d %H:%M:%S')} - {msg}", flush=True)

def apply_ip_ban(ip):
    log(f"ALERT: Malicious traffic detected from {ip}. Applying Ban...")
    banned_ips[ip] = time.time() + BAN_TIME
    # Attempt iptables rule insertion (if privileged)
    try:
        subprocess.run(["iptables", "-A", "INPUT", "-s", ip, "-j", "DROP"], check=True, stderr=subprocess.DEVNULL)
    except Exception:
        pass

def unban_expired():
    now = time.time()
    to_remove = []
    for ip, expire_time in banned_ips.items():
        if now >= expire_time:
            to_remove.append(ip)
            try:
                subprocess.run(["iptables", "-D", "INPUT", "-s", ip, "-j", "DROP"], check=True, stderr=subprocess.DEVNULL)
            except Exception:
                pass
    for ip in to_remove:
        del banned_ips[ip]
        log(f"UNBAN: Released IP {ip}")

def inspect_connections():
    now = time.time()
    try:
        # Scan socket activity via ss
        proc = subprocess.Popen(["ss", "-ntu"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        stdout, _ = proc.communicate()
    except Exception as e:
        return

    active_counts = collections.defaultdict(int)
    
    for line in stdout.splitlines():
        if "ESTAB" not in line and "SYN-SENT" not in line:
            continue
        parts = line.split()
        if len(parts) < 5:
            continue
        
        # Extract remote IP address
        r_addr = parts[4]
        if ":" in r_addr:
            ip = r_addr.rsplit(":", 1)[0].replace("[", "").replace("]", "")
            if ip in ("127.0.0.1", "::1", ""):
                continue
            
            active_counts[ip] += 1
            ip_history[ip].append(now)

            # Enforce max concurrency limit
            if active_counts[ip] > MAX_CONN_PER_IP and ip not in banned_ips:
                log(f"EXCEEDED CONCURRENCY: {ip} with {active_counts[ip]} connections.")
                apply_ip_ban(ip)

    # Enforce burst rate limits
    for ip, timestamps in list(ip_history.items()):
        # Prune timestamps older than window
        ip_history[ip] = [t for t in timestamps if now - t <= RATE_LIMIT_WINDOW]
        if len(ip_history[ip]) > MAX_REQ_PER_WINDOW and ip not in banned_ips:
            log(f"RATE LIMIT EXCEEDED: {ip} ({len(ip_history[ip])} reqs/{RATE_LIMIT_WINDOW}s)")
            apply_ip_ban(ip)

def main():
    log("Engine started. Monitoring sockets...")
    while True:
        try:
            unban_expired()
            inspect_connections()
        except Exception as e:
            pass
        time.sleep(2)

if __name__ == "__main__":
    main()
EOF

# --- 4. Log Cleaner Module (log_cleaner.py) ---
cat << 'EOF' > log_cleaner.py
import os
import time
import glob
import shutil

LOG_PATHS = [
    "/var/log/nginx/*.log",
    "/var/log/sshd.log",
    "/var/log/syslog",
    "/var/log/messages",
    "/var/log/auth.log",
    "/tmp/*.log"
]

CLEAN_INTERVAL = 120  # Runs every 2 minutes
MAX_FILE_SIZE_MB = 10 # Truncate if exceeds 10MB

def log(msg):
    print(f"[Log-Cleaner] {time.strftime('%Y-%m-%d %H:%M:%S')} - {msg}", flush=True)

def truncate_file(filepath):
    try:
        with open(filepath, 'w') as f:
            f.truncate(0)
        log(f"Truncated oversized log: {filepath}")
    except Exception:
        pass

def wipe_temp_cache():
    dirs_to_purge = ["/tmp", "/var/tmp", "/var/cache/nginx"]
    for path in dirs_to_purge:
        if os.path.exists(path):
            for item in os.listdir(path):
                target = os.path.join(path, item)
                try:
                    if os.path.isfile(target) and not target.endswith('.py'):
                        if time.time() - os.path.getmtime(target) > 300: # Older than 5 min
                            os.remove(target)
                except Exception:
                    pass

def purge_logs():
    for pattern in LOG_PATHS:
        for filepath in glob.glob(pattern):
            try:
                if os.path.isfile(filepath):
                    size_mb = os.path.getsize(filepath) / (1024 * 1024)
                    if size_mb > MAX_FILE_SIZE_MB:
                        truncate_file(filepath)
            except Exception:
                pass

def main():
    log("Engine active. Automatic log sanitization enabled...")
    while True:
        try:
            purge_logs()
            wipe_temp_cache()
        except Exception as e:
            pass
        time.sleep(CLEAN_INTERVAL)

if __name__ == "__main__":
    main()
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
        ""      "S2w0eVY4bTBRN3pQNjFqWA==";
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
    FINAL_CPU="2"; FINAL_RAM="2Gi"; FINAL_MIN="1"; FINAL_MAX="2"; FINAL_MODE="4) ⚡ BALANCED (FALLBACK)"
elif deploy_attempt 1 512Mi 1 2; then
    FINAL_CPU="1"; FINAL_RAM="512Mi"; FINAL_MIN="1"; FINAL_MAX="2"; FINAL_MODE="2) 🌱 ESSENTIAL (FALLBACK)"
else
    echo -e "  ${MAGENTA}ALL DEPLOY ATTEMPTS FAILED.${RESET}"
    echo -e "  ${CYAN}Check your actual quota at:${RESET}"
    echo -e "  https://console.cloud.google.com/iam-admin/quotas?project=${PROJECT_ID}"
    exit 1
fi

SERVICE_URL=$(gcloud run services describe "$SERVICE_NAME" --region "$REGION" --project="$PROJECT_ID" --format='value(status.url)' 2>/dev/null)
CLEAN_HOST=$(echo "$SERVICE_URL" | sed 's|https://||')

echo ""
echo -e "  ${GREEN} DEPLOYED SSH & VLESS SUCCESSFULLY${RESET}"
echo ""
echo -e "  ${CYAN}SERVICE NAME     : ${GREEN}${SERVICE_NAME}${RESET}"
echo -e "  ${CYAN}RAW HOST         : ${GREEN}${CLEAN_HOST}${RESET}"
echo -e "  ${CYAN}SERVER HOST      : ${GREEN}${SERVICE_URL}${RESET}"
echo -e "  ${CYAN}User/Pass        : ${GREEN}cxlvin : cxlvin${RESET}"
echo -e "  ${MAGENTA}--------------------------------------------------${NC}"
echo -e "  ${CYAN}VLESS CONFIG DETAILS:${RESET}"
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
