# 🖥️ Windows 10 in Docker Container

![Docker](https://img.shields.io/badge/Docker-2CA5E0?style=for-the-badge&logo=docker&logoColor=white)
![KVM](https://img.shields.io/badge/KVM-FF6600?style=for-the-badge&logo=linux&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-10-0078D6?style=for-the-badge&logo=windows&logoColor=white)

A Docker container solution for running Windows 10 with KVM acceleration, providing remote access via VNC and RDP.

## 🚀 Getting Started

### Prerequisites
- Docker installed
- KVM enabled system
- Administrative privileges

## 📦 Features

- ⚡ Run Windows 10 inside a Docker container
- 🔒 Secure with isolated environment
- 🖥️ Access via noVNC (web browser) or RDP
- 🚀 Fast virtualization using KVM (requires host support)
- 💾 Persistent storage using Docker volumes

---

## 🛠️ Requirements

- **Linux host** with:
  - KVM enabled (`/dev/kvm` should exist)
  - Docker installed
- **Windows 10 ISO** (for initial installation)
- Modern web browser (for noVNC access)

---

## 🚀 Installation

### 1. Clone the Repository
```bash
git clone https://github.com/hopingboyz/windows10vm
cd windows10vm
```

### 2. Build the image
```bash
docker build -t windows10-vm .
```

### 3. Start the VM
```bash
docker run -d \
  --name windowsvm \
  --device /dev/kvm \
  -p 6080:6080 \
  -v win_data:/data \
  -v win_iso:/iso \
  windows10-vm
```

### 4. Restart the VM
```bash
docker restart windowsvm
```

If the container does not exist or Docker reports that the name is already in
use, recreate it:
```bash
docker rm -f windowsvm || true
docker run -d \
  --name windowsvm \
  --device /dev/kvm \
  -p 6080:6080 \
  -v win_data:/data \
  -v win_iso:/iso \
  windows10-vm
```

### 5. Stop the VM
```bash
docker rm -f windowsvm
```

### 6. Open the browser
```text
http://localhost:6080/vnc.html
```

If you are in VS Code or another remote environment, use the forwarded port URL for port 6080 from the Ports panel instead of a stale localhost link.

### 7. Check logs if needed
```bash
docker ps
docker logs -f windowsvm
```

### 8. Check whether the main VM server is on
From the project directory, run:
```bash
chmod +x vm-status.sh
./vm-status.sh
```

It reports `ON` only when the Windows VM and its VNC server are both running.

The container must show both QEMU and websockify in its logs. If QEMU stops,
the container exits instead of leaving a noVNC page running without a VM.

This project currently exposes only the browser port needed for noVNC access: 6080.
