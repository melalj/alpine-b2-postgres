#!/bin/bash
set -e

required_vars="B2_ACCOUNT_ID B2_ACCESS_KEY RESTORE_ARCHIVE_NAME RESTORE_POSTGRES_HOST RESTORE_POSTGRES_PORT RESTORE_POSTGRES_USERNAME RESTORE_POSTGRES_PASSWORD RESTORE_DB_NAME"
 

for var in $required_vars; do
	if [ -z "$(eval echo \$$var)" ]; then
		echo "Error: Environment variable $var is not set."
		exit 1
	fi
done

echo "Authorizing B2 account"
/usr/bin/b2 authorize-account $B2_ACCOUNT_ID $B2_ACCESS_KEY

echo "Download $RESTORE_ARCHIVE_NAME from B2 bucket..."
/usr/bin/b2 download-file-by-name --noProgress $B2_BUCKET $RESTORE_ARCHIVE_NAME $RESTORE_ARCHIVE_NAME

echo "Restore Postgres database $RESTORE_DB_NAME from compressed archive..."
PGPASSWORD=$RESTORE_POSTGRES_PASSWORD /usr/bin/pg_restore $RESTORE_EXTRA_PARAMS $RESTORE_ARCHIVE_NAME -h $RESTORE_POSTGRES_HOST -p $RESTORE_POSTGRES_PORT -U $RESTORE_POSTGRES_USERNAME -d $RESTORE_DB_NAME -F tar -v $RESTORE_EXTRA_FLAGS

echo "Cleaning up compressed archive..."
rm "$RESTORE_ARCHIVE_NAME"

echo "Restore complete!"
exit 0
