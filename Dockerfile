FROM debian:jessie

RUN DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y isc-dhcp-server

ADD https://raw.githubusercontent.com/jpetazzo/pipework/master/pipework /pipework
ADD dhcpd.sh /dhcpd.sh
ADD dhcpd.conf.template /dhcpd.conf.template

RUN chmod +x /dhcpd.sh /pipework

ENV SUBNET _
ENV NETMASK _
ENV RANGE _
ENV GATEWAY _
ENV MYIP _

EXPOSE 67
EXPOSE 67/udp
EXPOSE 547
EXPOSE 547/udp
EXPOSE 647
EXPOSE 647/udp
EXPOSE 847
EXPOSE 847/udp

ENTRYPOINT ["/dhcpd.sh"]
CMD ["-f", "-cf", "/config/dhcpd.conf", "-lf", "/data/dhcpd.leases", "--no-pid"]
