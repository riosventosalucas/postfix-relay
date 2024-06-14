#!/bin/bash

# I'm using the environment domain for this script
sed -i "s/REMPLAZAME/$DOMAIN/g" /etc/postfix/main.cf

POSTFIX_BIN=$(which postfix)

RSYSLOGD_BIN=$(which rsyslogd)

$POSTFIX_BIN start

$RSYSLOGD_BIN

OPENDKIM_BIN=$(which opendkim)

mkdir -p /etc/opendkim/keys/$DOMAIN
/dev/null > /etc/opendkim/KeyTable  > /dev/null 2>&1
/dev/null > /etc/opendkim/SigningTable  > /dev/null 2>&1
echo -e "127.0.0.1\n::1" > /etc/opendkim/TrustedHosts

# If we dont have a valid domain config for dkim, create a new one
if [ ! -e "/etc/opendkim-volume/keys/$DOMAIN/default.private" ]; then
    echo -e "[ INFO ] No configuration file for $DOMAIN found."
    opendkim-genkey -s default -d $DOMAIN -D /etc/opendkim/keys/$DOMAIN
    chown -R opendkim:opendkim /etc/opendkim/keys/$DOMAIN
    chmod 600 /etc/opendkim/keys/$DOMAIN/default.private
    sed -i "s/REMPLAZAME/$DOMAIN/g" /etc/opendkim.conf
    echo "default._domainkey.$DOMAIN $DOMAIN:default:/etc/opendkim/keys/$DOMAIN/default.private" >> /etc/opendkim/KeyTable
    echo "*@$DOMAIN default._domainkey.$DOMAIN" >> /etc/opendkim/SigningTable
    echo "$DOMAIN" >> /etc/opendkim/TrustedHosts
    rsync -avpr --progress /etc/opendkim/ /etc/opendkim-volume > /dev/null 2>&1
else
    # If existing, we will use it
    echo -e "[ INFO ] DKIM configuration file for $DOMAIN found."
    sed -i "s/REMPLAZAME/$DOMAIN/g" /etc/opendkim.conf
    rsync -avpr --progress /etc/opendkim-volume/ /etc/opendkim > /dev/null 2>&1
fi

chown -R root:root /etc/opendkim*
find /etc/opendkim -type f -exec chmod 600 {} \;
find /etc/opendkim -type d -exec chmod 700 {} \;
chmod 600 /etc/opendkim/keys/$DOMAIN/default.private

$OPENDKIM_BIN -A

tail -f /var/log/maillog
