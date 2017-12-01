FROM alpine:3.6

LABEL maintainer="matsub<matsub.rk@gmail.com>"
LABEL authors="https://github.com/matsub/alpine-ikev2-vpn/graphs/contributors"

# Define a dynamic variable for Certificate CN
ENV VPNUSER 'testUserOne'
ENV VPNPASS 'testOnePass'

# Define a dynamic variable for DN
ENV CERT_C 'cn'
ENV CERT_O 'ilove'
ENV CERT_CN 'Free vpn'

# strongSwan Version
ARG TZ="Asia/Shanghai"
ARG SS_VERSION="https://download.strongswan.org/strongswan-5.5.3.tar.gz"

# Install dep packge , Configure,make and install strongSwan
RUN apk --update add build-base curl bash iproute2 iptables-dev openssl openssl-dev supervisor && mkdir -p /tmp/strongswan \
    && curl -Lo /tmp/strongswan.tar.gz $SS_VERSION && tar --strip-components=1 -C /tmp/strongswan -xf /tmp/strongswan.tar.gz \
    && cd /tmp/strongswan \
    && ./configure  --enable-eap-identity --enable-eap-md5 --enable-eap-mschapv2 --enable-eap-tls --enable-eap-ttls --enable-eap-peap --enable-eap-tnc --enable-eap-dynamic --enable-eap-radius --enable-xauth-eap  --enable-dhcp  --enable-openssl  --enable-addrblock --enable-unity --enable-certexpire --enable-radattr --enable-swanctl --enable-openssl --disable-gmp && make && make install && rm -rf /tmp/* && apk del build-base curl openssl-dev && rm -rf /var/cache/apk/* \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone 

# Create cert dir
RUN mkdir -p /data/key_files

# Copy configure file to ipsec\iptables
COPY ./conf/ipsec.conf /usr/local/etc/ipsec.conf 
COPY ./conf/strongswan.conf /usr/local/etc/strongswan.conf 
COPY ./conf/ipsec.secrets /usr/local/etc/ipsec.secrets
COPY ./conf/iptables /etc/sysconfig/iptables
COPY ./conf/supervisord.conf /etc/supervisord.conf

# Copy scripts
ADD ./scripts /usr/local/bin
RUN chmod +x /usr/local/bin/*

# Open udp 500\4500 port
EXPOSE 500:500/udp
EXPOSE 4500:4500/udp

ADD init.sh /init.sh
RUN chmod +x /init.sh
ENTRYPOINT ["/init.sh","/usr/bin/supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]
