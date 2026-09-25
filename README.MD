# Windows 10 in Docker Container

Run Windows 10 with QEMU/KVM and access it through noVNC in a browser.

## Requirements

- Linux host with Docker
- KVM enabled at `/dev/kvm`
- Windows 10 ISO support through the configured Docker volume
- Modern web browser

## Start

```bash
docker build -t windows10-vm .
docker run -d \
  --name windowsvm \
  --device /dev/kvm \
  -p 6080:6080 \
  -v win_data:/data \
  -v win_iso:/iso \
  windows10-vm
sleep 5
./vm-status.sh
```

Open `http://localhost:6080/vnc.html`, or use the forwarded port 6080 URL in VS Code. Only browser port 6080 is exposed; VNC port 5900 stays internal.

## Restart and Stop

```bash
docker restart windowsvm
sleep 5
./vm-status.sh
```

To recreate the container after rebuilding the image:

```bash
docker rm -f windowsvm || true
docker run -d \
  --name windowsvm \
  --device /dev/kvm \
  -p 6080:6080 \
  -v win_data:/data \
  -v win_iso:/iso \
  windows10-vm
sleep 5
./vm-status.sh
```

Stop and remove it with:

```bash
docker rm -f windowsvm
```

Check logs with:

```bash
docker logs -f windowsvm
```

`./vm-status.sh` reports `ON` only when both QEMU and its internal VNC server are available. Run it a few seconds after starting because QEMU needs time to open port 5900.

## GitHub Actions

The `Build Windows VM image` workflow runs on pushes to `main` and can be run manually from the repository's **Actions** tab. It builds the Docker image and uploads `windows10-vm.tar.gz` as a downloadable artifact.

The GitHub-hosted runner exports the image but does not run the Windows VM. Run the image on a Linux host with stable KVM support.
