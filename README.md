# alpine-b2-postgres

Alpine docker image with b2 and postgresql16-client with two scripts:

- `./backup.sh`: Backup a postgres database
- `./restore.sh`: Restore a postgres database

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
```

## Getting started

```sh
# Edit your .env

# Backup
docker run -it --rm --env-file .env $(docker build -q .) sh /backup.sh

# Restore
docker run -it --rm --env-file .env $(docker build -q .) sh /restore.sh
```
