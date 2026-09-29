#!/bin/bash
# Start the desktop + VNC + noVNC stack in a UCloud Sandbox (built-in desktop template).
# Idempotent: components already running are not restarted.
set -u
DISPLAY_NUM=":0"
RES="${DESKTOP_RES:-1280x800x24}"
export DISPLAY="$DISPLAY_NUM"
start_if_absent () {
  local pattern="$1"; shift
  if pgrep -f "$pattern" >/dev/null 2>&1; then
    echo "[skip] already running: $pattern"
    return 0
  fi
  setsid nohup "$@" >/dev/null 2>&1 < /dev/null &
  echo "[start] $pattern"
}
start_if_absent "Xvfb $DISPLAY_NUM" Xvfb "$DISPLAY_NUM" -ac -screen 0 "$RES" -nolisten tcp
sleep 2
start_if_absent "xfce4-session" startxfce4
sleep 5
start_if_absent "x11vnc" x11vnc -display "$DISPLAY_NUM" -forever -wait 50 -shared \
  -rfbport 5900 -nopw -noxdamage -noxfixes -nowf -noscr -ping 1 -repeat -speeds lan
sleep 2
if ! pgrep -f "novnc_proxy" >/dev/null 2>&1; then
  cd /opt/noVNC/utils || exit 1
  setsid nohup ./novnc_proxy --vnc localhost:5900 --listen 6080 \
    --web /opt/noVNC --heartbeat 30 >/dev/null 2>&1 < /dev/null &
  echo "[start] novnc_proxy"
fi
sleep 4
echo "--- processes ---"
pgrep -a Xvfb || true
pgrep -a xfce4-session || true
pgrep -a x11vnc || true
pgrep -a novnc_proxy || true
echo "--- listening ports ---"
(ss -ltn 2>/dev/null || netstat -ltn 2>/dev/null) | grep -E ':(5900|6080)' || echo "no 5900/6080 yet"
