#!/bin/sh
# Backup SQL

MYDMP=/usr/bin/mysqldump
REPORT_EMAIL=yohan@lepage.eu.org
DATE=`/bin/date +%Y%m%d-%H`
BKP=/var/backup/sql/${DATE}.sql

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

tar -czvf ${BKP}.tar.gz ${BKP}

if [ -x ${BKP}.tar.gz ]; then
  rm -f ${BKP}
fi

echo  "Backup SQL du ${DATE} \n" | mutt -x -a "${BKP}.tar.gz" -s "Backup SQL du ${DATE}" -- $REPORT_EMAIL

# Suppression des fichiers de plus de 7 jours
for file in "$( /usr/bin/find /var/backup/sql/ -type f -mtime +7 )"
do
	        /bin/rm -f $file
done

exit 0

