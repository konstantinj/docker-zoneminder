#!/bin/bash

TZ=${TZ:-UTC}

ZM_CONFIG=/etc/zm/zm.conf
ZM_SERVER_HOST=${ZM_SERVER_HOST:-localhost}
ZM_DB_TYPE=${ZM_DB_TYPE:-mysql}
ZM_DB_HOST=${ZM_DB_HOST:-mysql}
ZM_DB_PORT=${ZM_DB_PORT:-3306}
ZM_DB_USER=${ZM_DB_USER:-zoneminder}
ZM_DB_PASS=${ZM_DB_PASS:-zoneminder}

sed -i "s/\(ZM_SERVER_HOST\)=.*/\1=$ZM_SERVER_HOST/g" "$ZM_CONFIG"
sed -i "s/\(ZM_DB_TYPE\)=.*/\1=$ZM_DB_TYPE/g" "$ZM_CONFIG"
sed -i "s/\(ZM_DB_HOST\)=.*/\1=$ZM_DB_HOST/g" "$ZM_CONFIG"
sed -i "s/\(ZM_DB_PORT\)=.*/\1=$ZM_DB_PORT/g" "$ZM_CONFIG"
sed -i "s/\(ZM_DB_USER\)=.*/\1=$ZM_DB_USER/g" "$ZM_CONFIG"
sed -i "s/\(ZM_DB_PASS\)=.*/\1=$ZM_DB_PASS/g" "$ZM_CONFIG"

ln -sf "/usr/share/zoneinfo/$TZ" /etc/localtime
echo "$TZ" > /etc/timezone
echo "date.timezone = $TZ" > /etc/php.d/zoneminder.ini

if [[ "$@" = "bash" ]]
then
	exec "$@"
fi

until mysql -u "$ZM_DB_USER" -p"$ZM_DB_PASS" -h "$ZM_DB_HOST" -P "$ZM_DB_PORT" -e "USE zm;" &>/dev/null; do
	echo "Waiting for mysql to start..."
	sleep 2
done

DB_INITALIZED=$(mysql -u "$ZM_DB_USER" -p"$ZM_DB_PASS" -h "$ZM_DB_HOST" -P "$ZM_DB_PORT" -e "USE zm; SHOW TABLES;")
if [[ -z "$DB_INITALIZED" ]]
then
    echo -n "Database has not been initialized... "
    mysql -u "$ZM_DB_USER" -p"$ZM_DB_PASS" -h "$ZM_DB_HOST" -P "$ZM_DB_PORT" < "/usr/share/zoneminder/db/zm_create.sql"
    echo 'Done!'
fi

exec "$@"
