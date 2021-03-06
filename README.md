# mysql-backup-s3

Backup MySQL to S3 (supports periodic backups).  

Based on https://github.com/schickling/dockerfiles/tree/master/mysql-backup-s3

Added support for checking IAM credentials and using.

## Usage with provided keys

```sh
$ docker run -e S3_ACCESS_KEY_ID=key -e S3_SECRET_ACCESS_KEY=secret -e S3_BUCKET=my-bucket -e S3_PATH=backup -e MYSQL_USER=user -e MYSQL_PASSWORD=password -e MYSQL_HOST=localhost foundplaces/mysql-backup-s3
```

## Usage with IAM credentials

```sh
$ docker run -e S3_BUCKET=my-bucket -e S3_PATH=backup -e MYSQL_USER=user -e MYSQL_PASSWORD=password -e MYSQL_HOST=localhost foundplaces/mysql-backup-s3
```

### Automatic Periodic Backups

You can additionally set the `SCHEDULE` environment variable like `-e SCHEDULE="@daily"` to run the backup automatically.

More information about the scheduling can be found [here](http://godoc.org/github.com/robfig/cron#hdr-Predefined_schedules).
