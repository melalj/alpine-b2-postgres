#!/bin/bash
set -e

required_vars="B2_ACCOUNT_ID B2_ACCESS_KEY BACKUP_ARCHIVE_NAME BACKUP_POSTGRES_HOST BACKUP_POSTGRES_PORT BACKUP_POSTGRES_USERNAME BACKUP_POSTGRES_PASSWORD BACKUP_DB_NAME"

for var in $required_vars; do
	if [ -z "$(eval echo \$$var)" ]; then
		echo "Error: Environment variable $var is not set."
		exit 1
	fi
done

echo "Authorizing B2 account"
/usr/local/bin/b2 authorize-account $B2_ACCOUNT_ID $B2_ACCESS_KEY

echo "Dumping Postgres database $BACKUP_DB_NAME to compressed archive..."
PGPASSWORD=$BACKUP_POSTGRES_PASSWORD /usr/bin/pg_dump $BACKUP_EXTRA_PARAMS -h $BACKUP_POSTGRES_HOST -p $BACKUP_POSTGRES_PORT -U $BACKUP_POSTGRES_USERNAME -d $BACKUP_DB_NAME -v -F t -f $BACKUP_ARCHIVE_NAME $BACKUP_EXTRA_FLAGS


echo "Uploading $BACKUP_ARCHIVE_NAME to B2 bucket..."
/usr/local/bin/b2 upload-file --noProgress --sha1 $(sha1sum $BACKUP_ARCHIVE_NAME | awk '{print $1}') $B2_BUCKET $BACKUP_ARCHIVE_NAME $BACKUP_ARCHIVE_NAME

echo "Cleaning up compressed archive..."
rm "$BACKUP_ARCHIVE_NAME"


if [ -n "$THIN_ARCHIVE_NAME" ]; then
	/bin/bash /thin.sh
fi

echo "Backup complete!"
exit 0
