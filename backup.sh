#!/bin/bash

set -e

# DB_NAME=XXX
# B2_ACCOUNT_ID=XXX
# B2_ACCESS_KEY=XXX
# B2_BUCKET=XXX
# ARCHIVE_NAME=XXX.sql.gz
# POSTGRES_HOST=XXX
# POSTGRES_USER=XXX
# POSTGRES_PASSWORD=XXX
# EXTRAFLAGS=


echo "Authorizing B2 account"
/usr/local/bin/b2 authorize-account ${B2_ACCOUNT_ID} ${B2_ACCESS_KEY}


echo "Dumping MongoDB databases ${DB_NAME} to compressed archive..."
PGPASSWORD=$POSTGRES_PASSWORD /usr/bin/pg_dump -h $POSTGRES_HOST -U $POSTGRES_USER $EXTRAFLAGS > $ARCHIVE_NAME

echo "Uploading ${ARCHIVE_NAME} to S3 bucket..."
/usr/local/bin/b2 upload-file --noProgress --sha1 $(sha1sum $ARCHIVE_NAME | awk '{print $1}') ${B2_BUCKET} $ARCHIVE_NAME $ARCHIVE_NAME

echo "Cleaning up compressed archive..."
rm "$ARCHIVE_NAME"

echo "Backup complete!"
exit 0
