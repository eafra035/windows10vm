FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    qemu-system-x86 \
    qemu-utils \
    novnc \
    websockify \
    wget \
    curl \
    net-tools \
    iproute2 \
    unzip \
    python3 \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /data /iso /novnc

RUN wget https://github.com/novnc/noVNC/archive/refs/heads/master.zip -O /tmp/novnc.zip && \
    unzip /tmp/novnc.zip -d /tmp && \
    mv /tmp/noVNC-master/* /novnc && \
    rm -rf /tmp/novnc.zip /tmp/noVNC-master

ENV ISO_URL="https://archive.org/download/windows-10-lite-edition-19h2-x64/Windows%2010%20Lite%20Edition%2019H2%20x64.iso"

RUN cat > /start.sh <<'EOF'
#!/bin/bash
set -e
trap '' TERM INT

if [ -e /dev/kvm ]; then
  echo "✅ KVM acceleration available"
  KVM_ARG="-enable-kvm"
  CPU_ARG="host"
  MEMORY="4G"
  SMP_CORES=2
else
  echo "⚠️  KVM not available - using slower emulation mode"
  KVM_ARG=""
  CPU_ARG="qemu64"
  MEMORY="2G"
  SMP_CORES=1
fi

MACHINE_ARG="q35,accel=tcg"
if [ -n "$KVM_ARG" ]; then
  MACHINE_ARG="q35,accel=kvm:tcg"
fi

if [ ! -f "/iso/os.iso" ]; then
  echo "📥 Downloading Windows 10 ISO..."
  wget -q --show-progress "$ISO_URL" -O "/iso/os.iso"
fi

if [ ! -f "/data/disk.qcow2" ]; then
  echo "💽 Creating 100GB virtual disk..."
  qemu-img create -f qcow2 "/data/disk.qcow2" 100G
fi

BOOT_ORDER="-boot order=c,menu=on"
if [ ! -s "/data/disk.qcow2" ] || [ $(stat -c%s "/data/disk.qcow2") -lt 1048576 ]; then
  echo "🚀 First boot - installing Windows from ISO"
  BOOT_ORDER="-boot order=d,menu=on"
fi

echo "⚙️ Starting Windows 10 VM with ${SMP_CORES} CPU cores and ${MEMORY} RAM"

websockify --web /novnc 6080 localhost:5900 &

echo "===================================================="
echo "🌐 Connect via browser: http://localhost:6080"
echo "❗ First boot may take 20-30 minutes for Windows install"
echo "===================================================="

qemu-system-x86_64 \
  $KVM_ARG \
  -machine "$MACHINE_ARG" \
  -cpu $CPU_ARG \
  -m $MEMORY \
  -smp $SMP_CORES \
  -vga std \
  -usb -device usb-tablet \
  $BOOT_ORDER \
  -drive file=/data/disk.qcow2,format=qcow2 \
  -drive file=/iso/os.iso,media=cdrom \
  -netdev user,id=net0 \
  -device e1000,netdev=net0 \
  -display none \
  -vnc :0 \
  -monitor none \
  -name "Windows10_VM" \
  > /data/qemu.log 2>&1 &

tail -f /dev/null
EOF

RUN chmod +x /start.sh

VOLUME ["/data", "/iso"]
EXPOSE 6080
CMD ["/start.sh"]
