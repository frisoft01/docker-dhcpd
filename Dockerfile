FROM alpine:3.20

ARG WEBMIN_VERSION=2.202
COPY config/webmin.exp /

RUN apk add --no-cache bash dhcp net-tools supervisor rsyslog logrotate perl perl-net-ssleay openssl perl-io-tty ca-certificates apkbuild-cpan expect git zsh && \
    mkdir -p /opt && cd /opt && \
    wget -q -O - "https://sourceforge.net/projects/webadmin/files/webmin/${WEBMIN_VERSION}/webmin-${WEBMIN_VERSION}.tar.gz" | tar xz && \
    ln -sf /opt/webmin-${WEBMIN_VERSION} /opt/webmin && \
    /usr/bin/expect /webmin.exp && rm /webmin.exp && \
    rm -rf /var/cache/apk/* && \
    mkdir -p /var/log/supervisor && \
    mkdir -p /run/dhcp/dhcpd.pid


ADD dhcpd/dhcpd.sh dhcpd/dhcpd.conf.template /usr/share/dhcpd/
ADD dhcpd/dhcpd-reservations.conf /etc/dhcpd-reservations.conf
ADD supervisor/supervisord.conf /etc/supervisord.conf
ADD rsyslogd/rsyslog.conf /etc/rsyslog.conf
ADD supervisor/conf.d /usr/share/supervisor/conf.d/
ADD logrotate/logrotate.conf /etc/logrotate.conf
ADD logrotate/dhcpd /etc/logrotate.d/dhcpd
ADD config/webmin/dhcpd/config /etc/webmin/dhcpd/config

ENV SUBNET= NETMASK= RANGE_PXE= RANGE_STATIC= RANGE_OTHER= GATEWAY= SERVER_IP= NAMESERVERS= \
    DEFAULT_LEASE_TIME=600 \
    MAX_LEASE_TIME=1800

EXPOSE 67 67/udp 10000

VOLUME ["/var/lib/dhcp","/etc/dhcp"]

# ENTRYPOINT ["supervisord"]
ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]

#CMD ["/bin/bash"]
