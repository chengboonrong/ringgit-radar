#!/bin/sh
# Dumps the database to $BACKUP_DIR (custom format, restorable with pg_restore) and keeps 14 days of dumps.
# Any failure exits non-zero, so systemd marks the run failed. DATABASE_URL comes from the EnvironmentFile.
# pg_dump must be at least the server's major version, or it refuses; install postgresql-client-<major>.
set -eu
: "${DATABASE_URL:?DATABASE_URL is not set}"
dir="${BACKUP_DIR:-/var/backups/ringgit-radar}"
keep_days=14
umask 077
mkdir -p "$dir"
stamp="$(date -u +%Y%m%dT%H%M%SZ)"
part="$dir/ringgit-$stamp.dump.part"
final="$dir/ringgit-$stamp.dump"
trap 'rm -f "$part"' EXIT

pg_dump --format=custom --schema=public --no-owner --no-privileges --dbname="$DATABASE_URL" --file="$part"
# a dump that cannot be listed is not a backup
pg_restore --list "$part" > /dev/null
mv "$part" "$final"
echo "wrote $final ($(wc -c < "$final") bytes)"

# only after a good dump, drop the ones older than 14 days
find "$dir" -maxdepth 1 -name 'ringgit-*.dump' -type f -mtime "+$keep_days" -print -delete
