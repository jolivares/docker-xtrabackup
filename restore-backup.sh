#!/bin/bash

if [ -z "$backup_file" ]; then
    echo "Need to set backup_file"
    exit 1
fi

dst_dir=/var/mysql/data
mkdir -p $dst_dir

if [[ $backup_file == *.tar.gz ]]; then
    format="tar"
fi

if [ "$format" = "tar" ]; then
    echo "Extracting /backup/${backup_file} to ${dst_dir}..."
    tar -izxvf /backup/$backup_file -C $dst_dir
    if [ $? -ne 0 ]; then
        echo "Error: extracting backup file '$backup_file' to '$dst_dir' failed!!!" >&2
        exit 1
    else
        echo "Done."
    fi
# unsupported format
else
    echo "Error: unknown backup file format, only xxx.tar.gz file format is supported." >&2
    exit 1
fi

innobackupex --defaults-file=$dst_dir/backup-my.cnf --apply-log $dst_dir
if [ $? -ne 0 ]; then
	echo "Error: applying log to backup backup data failed!!!" >&2
    df -h
    exit 1
fi

binlog_coordinates=$(cat $dst_dir/xtrabackup_binlog_info)
echo "Binlog: ${binlog_coordinates}" >&2
echo "####### BACKUP IS READY!!" >&2

chown -R mysql:mysql $dst_dir

su -c "mysqld_safe --log-error=/var/log/mysql/error.log --user=mysql --datadir=$dst_dir --skip-grant-tables" -m mysql
cat /var/log/mysql/error.log


