#!/usr/bin/env bash

pgrecoverhost="pg01"
pgmaster="172.28.33.12"

echo "Starting ..."
echo "Get node out of the group"
crm node standby $pgrecoverhost
while killall -0 postgres; do
    sleep 0.5
done
echo "Delete /var/lib/postgresql/tmp/PGSQL.lock"
rm -f /var/lib/postgresql/tmp/PGSQL.lock
echo "Delete /var/lib/postgresql/9.6/main/recovery.conf"
rm -f /var/lib/postgresql/9.6/main/recovery.conf
echo "Delete /var/lib/postgresql/9.6/main/pg_xlog/*"
rm -fr /var/lib/postgresql/9.6/main/pg_xlog/*
echo "Delete /var/lib/postgresql/9.6/main/*"
rm -fr /var/lib/postgresql/9.6/main/*
echo "Base backup from master"
pg_basebackup -v -p 5432 -U postgres -h $pgmaster -X stream -R -P -D /var/lib/postgresql/9.6/main
echo "Fix directory permissions"
chown -R postgres:postgres /var/lib/postgresql/9.6/main
echo "Activating node again"
crm node online $pgrecoverhost
while ! crm resource cleanup Postgresql; do
    sleep 0.5
done
echo "Done `date`"
