#!/bin/sh

container="windowsvm"

if ! docker inspect "$container" >/dev/null 2>&1; then
  echo "OFF: container $container does not exist"
  exit 1
fi

container_status=$(docker inspect --format '{{.State.Status}}' "$container")
if [ "$container_status" != "running" ]; then
  echo "OFF: container status is $container_status"
  exit 1
fi

if ! docker exec "$container" sh -c 'pgrep -f "qemu-system-x86_64" >/dev/null 2>&1'; then
  echo "OFF: Windows VM server is not running"
  exit 1
fi

if docker exec "$container" sh -c 'python3 -c "import socket; s=socket.create_connection((\"127.0.0.1\",5900),2); s.close()"' >/dev/null 2>&1; then
  echo "ON: Windows VM server is running"
  echo "Browser: http://localhost:6080/vnc.html"
  exit 0
fi

echo "OFF: QEMU is running but the VNC server is not ready"
exit 1