#!/bin/bash

required_vars="B2_ACCOUNT_ID B2_ACCESS_KEY B2_BUCKET THIN_ARCHIVE_NAME"

for var in $required_vars; do
	if [ -z "$(eval echo \$$var)" ]; then
		echo "Error: Environment variable $var is not set."
		exit 1
	fi
done

KEEP_HOURLY_FOR_IN_HOURS=${KEEP_HOURLY_FOR_IN_HOURS:-24}
KEEP_DAILY_FOR_IN_DAYS=${KEEP_DAILY_FOR_IN_DAYS:-30}
KEEP_WEEKLY_FOR_IN_WEEKS=${KEEP_WEEKLY_FOR_IN_WEEKS:-52}
KEEP_MONTHLY_FOR_IN_MONTHS=${KEEP_MONTHLY_FOR_IN_MONTHS:-60}

echo "Authorizing B2 account"
/usr/bin/b2 authorize-account $B2_ACCOUNT_ID $B2_ACCESS_KEY

# Function to delete versions of a file based on retention policy
delete_versions_based_on_policy() {
    local current_date=$(date +%s)
    declare -A seen_hourly seen_daily seen_weekly seen_monthly

    # List versions of the file
    /usr/bin/b2 ls --long --versions "$B2_BUCKET" | awk '{print $3, $4, $1, $6}' | sort -r | while read -r line; do
        
        # Extract the date, time, and version info
        local file_date=$(echo $line | awk '{print $1}')
        local file_time=$(echo $line | awk '{print $2}')
        local file_version_id=$(echo $line | awk '{print $3}')
        local file_name=$(echo $line | awk '{print $4}')

        if [ "$file_name" != "$THIN_ARCHIVE_NAME" ]; then
            continue
        fi

        # Combine date and time, and convert to Unix timestamp
        local file_datetime="$file_date $file_time"
        local file_ts=$(date -d "$file_datetime" +%s)


        # Calculate the age of the file in hours, days, and weeks
        local file_age_hours=$(( (current_date - file_ts) / 3600 ))
        local file_age_days=$((file_age_hours / 24))
        local file_week=$(date -d "$file_date" +%Y-%V)
        local file_month=$(date -d "$file_date" +%Y-%m)

        # Apply retention policies
        if [ $file_age_hours -le $KEEP_HOURLY_FOR_IN_HOURS ]; then
            # For KEEP_HOURLY_FOR_IN_HOURS hours, keep only one backup per hour
            if [[ -z ${seen_hourly[$file_date]} ]]; then
                # This is the first backup of the day, keep it
                echo "kept(hourly): $file_datetime"
                seen_hourly[$file_date]=1
            else
                # Subsequent backup for the day, delete it
                echo "deleting: $file_datetime"
                /usr/bin/b2 delete_file_version "$THIN_ARCHIVE_NAME" "$file_version_id" > /dev/null
                echo " ok"
            fi
        elif [ $file_age_days -le $KEEP_DAILY_FOR_IN_DAYS ]; then
            # For KEEP_DAILY_FOR_IN_DAYS days, keep only one backup per day
            if [[ -z ${seen_daily[$file_date]} ]]; then
                # This is the first backup of the day, keep it
                echo "kept(daily): $file_datetime"
                seen_daily[$file_date]=1
            else
                # Subsequent backup for the day, delete it
                echo "deleting: $file_datetime"
                /usr/bin/b2 delete_file_version "$THIN_ARCHIVE_NAME" "$file_version_id" > /dev/null
                echo " ok"
            fi
        elif [ $file_age_days -le $(($KEEP_WEEKLY_FOR_IN_WEEKS * 7)) ]; then
            # For KEEP_WEEKLY_FOR_IN_WEEKS weeks, keep only the first backup of each week
            if [[ -z ${seen_weekly[$file_week]} ]]; then
              echo "kept(weekly): $file_datetime"
              seen_weekly[$file_week]=1
            else
                echo "deleting: $file_datetime"
                /usr/bin/b2 delete_file_version "$THIN_ARCHIVE_NAME" "$file_version_id" > /dev/null
                echo " ok"
            fi
        elif [ $file_age_days -le $(($KEEP_MONTHLY_FOR_IN_MONTHS * 30)) ]; then
            # For 60 months, keep only the first backup of each month
            if [[ -z ${seen_monthly[$file_month]} ]]; then
                seen_monthly[$file_month]=1
                echo "kept(monthly): $file_datetime"
            else
                echo "deleting: $file_datetime"
                /usr/bin/b2 delete_file_version "$THIN_ARCHIVE_NAME" "$file_version_id" > /dev/null
                echo " ok"
            fi
        else
            # Delete backups older than KEEP_MONTHLY_FOR_IN_MONTHS months
            echo deleted "$THIN_ARCHIVE_NAME" "$file_datetime"
            /usr/bin/b2 delete_file_version "$THIN_ARCHIVE_NAME" "$file_version_id" > /dev/null
        fi
    done
}

# Apply retention policies
delete_versions_based_on_policy

echo "Backup thinning complete."