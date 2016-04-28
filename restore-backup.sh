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
    echo "Extracting to ${dst_dir}..."
    tar -izxvf $backup_file -C $dst_dir
    if [ $? -ne 0 ]; then
        echo "Error: extracting backup file '$backup_file' to '$dst_dir' failed!!!" >&2
        rm -rf $tmp_dir
        exit 1
    else
        echo "Done."
    fi
# unsupported format
else
    echo "Error: unknown backup file format, only xxx.tar.gz file format is supported." >&2
    Usage
    rm -rf $tmp_dir
    exit 1
fi

innobackupex --defaults-file=$dst_dir/backup-my.cnf --apply-log $dst_dir
if [ $? -ne 0 ]; then
	echo "Error: applying log to backup backup data failed!!!" >&2
    rm -rf $tmp_dir
    exit 1
fi

echo "Backup is ready!!" >&2

chown -R mysql:mysql $dst_dir

su -c "mysqld_safe --defaults-file=$dst_dir/backup-my.cnf --user=mysql --datadir=$dst_dir --skip-grant-tables" -m mysql


