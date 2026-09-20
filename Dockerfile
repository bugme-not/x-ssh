FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

# Install dependencies, build tools, OpenSSH, and configure OpenResty APT repo
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    bash \
    curl \
    tzdata \
    wget \
    supervisor \
    python3 \
    python3-pip \
    iptables \
    iproute2 \
    unzip \
    git \
    cmake \
    build-essential \
    gnupg \
    lsb-release \
    openssh-server \
    && wget -qO - https://openresty.org/package/pubkey.gpg | apt-key add - \
    && echo "deb http://openresty.org/package/ubuntu $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/openresty.list \
    && apt-get update && apt-get install -y openresty \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Xray Core
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
    && make install \
    && rm -rf /tmp/badvpn

# Configure SSH User and Service Directories
RUN mkdir -p /var/run/sshd /run/sshd \
    && useradd -m -s /bin/bash cxlvin \
    && echo 'cxlvin:cxlvin' | chpasswd

RUN { \
    echo "PermitRootLogin yes"; \
    echo "PasswordAuthentication yes"; \
    echo "UseDNS no"; \
    echo "TCPKeepAlive yes"; \
    echo "ClientAliveInterval 15"; \
    echo "ClientAliveCountMax 3"; \
    echo "MaxSessions 50"; \
    echo "MaxStartups 50:30:100"; \
    echo "Compression no"; \
    } >> /etc/ssh/sshd_config

# Copy Python scripts, entrypoint, and configurations
COPY sub_server.py /app/sub_server.py
COPY anti_ddos.py /app/anti_ddos.py
COPY entrypoint.sh /app/entrypoint.sh

COPY config.json /etc/xray.json
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY supervisord.conf /etc/supervisord.conf

RUN chmod +x /app/entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
