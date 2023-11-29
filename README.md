# alpine-b2-postgres

Alpine docker image with b2 and postgresql-client with two scripts:

- `./backup.sh`: Backup a postgres database
- `./restore.sh`: Restore a postgres database

```sh
# Edit your .env

# Backup
docker run -it --rm --env-file .env $(docker build -q .) sh /backup.sh

# Restore
docker run -it --rm --env-file .env $(docker build -q .) sh /restore.sh
```
