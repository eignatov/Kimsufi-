#!/bin/bash
set -x
RKHUNTER=/usr/bin/rkhunter
REPORT_EMAIL="yohan@lepage.eu.org"

if [ ! -x $RKHUNTER ]; then
  exit 0
fi
OUTFILE=`mktemp` || exit 1

$RKHUNTER --cronjob --update
$RKHUNTER --cronjob --report-warnings-only --createlogfile /var/log/rkhunter.log > $OUTFILE

if [ $(stat -c %s $OUTFILE) -ne 0 ]
then
	(
		echo "Subject: [rootkit] Scan journalier"
		echo ""
		cat $OUTFILE
	) | /usr/sbin/sendmail $REPORT_EMAIL
fi

rm -rf $OUTFILE
