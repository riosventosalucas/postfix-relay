FROM almalinux:8

# First, update and install the repository
RUN yum update -y && yum install -y epel-release

# Now, install some packages
RUN yum install -y vim mlocate net-tools telnet git wget postfix rsyslog procps-ng opendkim opendkim-tools rsync

# This is only for me if you don't want to use vi as vim just comment out
RUN alias vi=vim

# Copy the postfix main config
COPY ./src/main.cf /etc/postfix/.

# This is a script that do everything 
COPY ./src/docker-entrypoint.sh /root/.

# Rsyslog config for logging
COPY ./src/rsyslog-postfix.conf /etc/rsyslog.d/postfix.conf

# Set the opendkim configuration file
COPY ./src/opendkim.conf /etc/.

# Fix some permissions
RUN chmod 600 /etc/postfix/main.cf

RUN chmod +x /root/docker-entrypoint.sh

RUN postalias /etc/aliases

# The entry point
ENTRYPOINT [ "/root/docker-entrypoint.sh" ]