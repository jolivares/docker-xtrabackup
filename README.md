# Goal
Docker image which contains Percona MySQL Server and Percona XtraBackup. 
It allows to import an Percona MySQL backup from a tar.gz file into the contained Percona MySQL Server.
# Usage
```
docker run -p 3306:3306 -v /path-to-backup-dir:/backup --env backup_file=/backup.tar.gz jolivares/xtrabackup
```
MySQL Server is started using `--skip-grant-tables` so no need to use user/password
