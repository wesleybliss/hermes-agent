#!/bin/sh
BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)
FILENAME="local_${DATE}.sql.gz"

# pg_dumpall --column-inserts --inserts --no-comments | gzip > "${BACKUP_DIR}/${FILENAME}"

pg_dump --create --column-inserts --inserts --no-comments | gzip > "${BACKUP_DIR}/${FILENAME}"

# Keep only last 7 backups
ls -t ${BACKUP_DIR}/local_*.sql.gz | tail -n +8 | xargs -r rm
