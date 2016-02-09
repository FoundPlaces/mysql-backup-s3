#! /bin/sh

set -e

if [ "${MYSQL_HOST}" = "**None**" ]; then
  echo "You need to set the MYSQL_HOST environment variable."
  exit 1
fi

if [ "${MYSQL_USER}" = "**None**" ]; then
  echo "You need to set the MYSQL_USER environment variable."
  exit 1
fi

if [ "${MYSQL_PASSWORD}" = "**None**" ]; then
  echo "You need to set the MYSQL_PASSWORD environment variable or link to a container named MYSQL."
  exit 1
fi


if [ "${S3_BUCKET}" = "**None**" ]; then
  echo "You need to set the S3_BUCKET environment variable."
  exit 1
fi
export AWS_DEFAULT_REGION=$S3_REGION


aws s3 ls $S3_BUCKET >/dev/null 2>&1

if [ $? -ne 0 ]
then
#Check for Access Keys
  if [ "${S3_ACCESS_KEY_ID}" = "**None**" ]; then
    echo "You need to set the S3_ACCESS_KEY_ID environment variable."
    exit 1
  fi

  if [ "${S3_SECRET_ACCESS_KEY}" = "**None**" ]; then
    echo "You need to set the S3_SECRET_ACCESS_KEY environment variable."
    exit 1
  fi

  # env vars needed for aws tools
  export AWS_ACCESS_KEY_ID=$S3_ACCESS_KEY_ID
  export AWS_SECRET_ACCESS_KEY=$S3_SECRET_ACCESS_KEY
else
  echo "Using IAM credentials"
fi

MYSQL_HOST_OPTS="-h $MYSQL_HOST --port $MYSQL_PORT -u $MYSQL_USER -p$MYSQL_PASSWORD"

echo "Creating dump of ${MYSQLDUMP_DATABASE} database(s) from ${MYSQL_HOST}..."

exec 4>&1                                                                                                                                                                                                                                        
status=`{ { mysqldump $MYSQL_HOST_OPTS $MYSQLDUMP_OPTIONS $MYSQLDUMP_DATABASE; printf $? 1>&3; } | gzip 1>&4 > dump.sql.gz; } 3>&1 `                                                                                                             
                                                                                                                                                                                                                                                 
if [ ${status} -ne 0 ]                                                                                                                                                                                                                           
then                                                                                                                                                                                                                                             
  echo "Mysqldump failed. See error"                                                                                                                                                                                                             
  exit 1                                                                                                                                                                                                                                         
fi                                                                                                                                                                                                                                               

echo "Uploading dump to $S3_BUCKET"

cat dump.sql.gz | aws s3 cp - s3://$S3_BUCKET/$S3_PATH/$(date +"%Y-%m-%dT%H%M%SZ").sql.gz || exit 2

echo "SQL backup uploaded successfully"
