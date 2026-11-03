#!/bin/sh
# Installs the nightly sweep and backup on a Raspberry Pi. Run as root over SSH, from this folder, after
# copying the folder and the collector binary (built on the Mac, see below) to the Pi:
#
#   # on the Mac, from backend/ (a Pi 3B on a 64-bit OS; on a 32-bit OS use GOARCH=arm GOARM=7)
#   CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -trimpath -ldflags="-s -w" -o deploy/pi/collector-linux-arm64 ./cmd/collector
#   scp -r deploy/pi pi@raspberrypi.local:ringgit-pi
#   # on the Pi
#   sudo sh ringgit-pi/install.sh
#
# It never overwrites /etc/ringgit-radar/env. It does not start a sweep; run one by hand to test:
#   sudo systemctl start ringgit-collector.service && journalctl -u ringgit-collector -n 30
set -eu
here="$(cd "$(dirname "$0")" && pwd)"
[ "$(id -u)" -eq 0 ] || { echo "run as root: sudo sh $0" >&2; exit 1; }
[ -f "$here/collector-linux-arm64" ] || { echo "collector-linux-arm64 is missing next to this script" >&2; exit 1; }

id ringgit >/dev/null 2>&1 || useradd --system --home-dir /opt/ringgit-radar --shell /usr/sbin/nologin ringgit
install -d -o root -g root -m 755 /opt/ringgit-radar
install -d -o ringgit -g ringgit -m 700 /var/backups/ringgit-radar
install -d -o root -g root -m 755 /etc/ringgit-radar
install -o root -g root -m 755 "$here/collector-linux-arm64" /opt/ringgit-radar/collector
install -o root -g root -m 755 "$here/backup.sh" /opt/ringgit-radar/backup.sh
if [ ! -e /etc/ringgit-radar/env ]; then
  install -o root -g root -m 600 "$here/env.example" /etc/ringgit-radar/env
  echo "created /etc/ringgit-radar/env from the example: edit it and put the real DATABASE_URL in"
fi
install -o root -g root -m 644 "$here"/ringgit-collector.service "$here"/ringgit-collector.timer \
  "$here"/ringgit-backup.service "$here"/ringgit-backup.timer /etc/systemd/system/

# pg_dump must be at least the server's major version
if command -v pg_dump >/dev/null 2>&1; then echo "pg_dump: $(pg_dump --version)"; else echo "pg_dump is missing: apt install postgresql-client-17 (match the Supabase major version, from the PGDG repository if apt has an older one)" >&2; fi

systemctl daemon-reload
systemctl enable --now ringgit-collector.timer ringgit-backup.timer
systemctl list-timers 'ringgit-*' --no-pager
echo "done. The Mac's launchd sweep must not run at the same time: bootout com.eshopradar.collector there first."
