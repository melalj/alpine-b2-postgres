# alpine-b2-postgres

Alpine docker image with b2 and postgresql16-client with two scripts:

- `./backup.sh`: Backup a postgres database
- `./restore.sh`: Restore a postgres database
- `./thin.sh`: Thin backblaze backup (rotate to keep hourly, daily, weekly, monthly)

## Environement variables

```sh
# B2
B2_ACCOUNT_ID=xxx
B2_ACCESS_KEY=xxx
B2_BUCKET=xxx

# BACKUP
BACKUP_ARCHIVE_NAME=xxx.sql.tar
BACKUP_POSTGRES_HOST=xxx
BACKUP_POSTGRES_PORT=6432
BACKUP_POSTGRES_USERNAME=postgres
BACKUP_POSTGRES_PASSWORD=xxx
BACKUP_DB_NAME=xxx
BACKUP_EXTRA_PARAMS=
BACKUP_EXTRA_FLAGS=--no-owner --no-privileges --no-acl

# RESTORE
RESTORE_ARCHIVE_NAME=xxx.sql.tar
RESTORE_POSTGRES_HOST=xxx
RESTORE_POSTGRES_PORT=6432
RESTORE_POSTGRES_USERNAME=postgres
RESTORE_POSTGRES_PASSWORD=xxx
RESTORE_DB_NAME=xxx
RESTORE_EXTRA_PARAMS=
RESTORE_EXTRA_FLAGS=--clean --if-exists --no-owner --no-privileges --no-acl

# THIN
THIN_ARCHIVE_NAME=xxx.gz
KEEP_HOURLY_FOR_IN_HOURS=24
KEEP_DAILY_FOR_IN_DAYS=30
KEEP_WEEKLY_FOR_IN_WEEKS=52
KEEP_MONTHLY_FOR_IN_MONTHS=60
```

## Getting started

```sh
# Edit your .env

# Backup
docker run -it --rm --env-file .env $(docker build -q .) bash /backup.sh

# Restore
docker run -it --rm --env-file .env $(docker build -q .) bash /restore.sh

# Thin
docker run -it --rm --env-file .env $(docker build -q .) bash /thin.sh

```
