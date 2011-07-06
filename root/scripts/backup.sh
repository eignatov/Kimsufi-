#!/bin/sh
# Backup SQL et FTP

set -x 

MYDMP=/usr/bin/mysqldump
REPORT_EMAIL=yohan@lepage.eu.org
DATE=`/bin/date +%Y%m%d-%H`
BKP=/var/backup/sql/${DATE}.sql
LIST=/root/scripts/backup.dir
SRV="127.0.0.1"
USER="user"
PASS="pass"

if [ ! -x $MYDMP ]; then
  exit 0
fi

mkdir --parent /var/backup/sql 

$MYDMP	--user=root \
	--password=bonjour \
	--lock-all-tables \
	--all-databases \
	--skip-comments \
	--compatible=no_table_options,no_field_options,no_key_options  > ${BKP}


cat $LIST | xargs tar zcf /var/backup/${DATE}.tar.gz

#echo  "Backup SQL du ${DATE} \n" | mutt -x -a "${BKP}.tar.gz" -s "Backup SQL du ${DATE}" -- $REPORT_EMAIL

cd /var/backup/
ftp -n << EOF
open $SRV
user $USER $PASS
ascii
put ${DATE}.tar.gz
EOF


# Suppression des fichiers de plus de 3 jours
for file in "$( /usr/bin/find /var/backup/ -type f -mtime 3 )"
do
	        /bin/rm -f $file
done


exit 0

