FROM ubuntu:20.04 

ENV SQUID_VERSION=3.5.27 \
    SQUID_CACHE_DIR=/var/spool/squid \
    SQUID_LOG_DIR=/var/log/squid \
    SQUID_USER=proxy


RUN apt update && apt install pgp wget -y
RUN wget -qO - https://packages.diladele.com/diladele_pub.asc | apt-key add -
RUN echo "deb https://squid413-ubuntu20.diladele.com/ubuntu/ focal main" > /etc/apt/sources.list.d/squid413-ubuntu20.diladele.com.list
RUN apt update
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -y install tzdata
RUN apt-get install -y \
    squid-common \
    squid-openssl \
    squidclient \
    libnss3-tools \
    libecap3 libecap3-dev apache2-utils

WORKDIR /etc/squid/ 
RUN wget https://github.com/FiloSottile/mkcert/releases/download/v1.4.3/mkcert-v1.4.3-linux-amd64
RUN mv mkcert-v1.4.3-linux-amd64 /usr/bin/mkcert
RUN chmod +x /usr/bin/mkcert
RUN mkcert 192.168.1.89
RUN head -n 12 /etc/ssl/openssl.cnf > /etc/ssl/_openssl.cnf && tail -n +14 /etc/ssl/openssl.cnf >> /etc/ssl/_openssl.cnf && mv /etc/ssl/_openssl.cnf /etc/ssl/openssl.cnf
RUN head -n 59 /etc/ssl/openssl.cnf > /etc/ssl/_openssl.cnf && tail -n +61 /etc/ssl/openssl.cnf >> /etc/ssl/_openssl.cnf && mv /etc/ssl/_openssl.cnf /etc/ssl/openssl.cnf

RUN touch /etc/squid/passwd && chown -R proxy:proxy /etc/squid/passwd

COPY . .
#RUN sh ./generate_cert_docker.sh
RUN touch blacklist && touch whitelist && cp whitelist whitelist_ssl && cp blacklist blacklist_ssl
RUN cat 192.168.1.89.pem 192.168.1.89-key.pem >> squid.pem
RUN /etc/init.d/squid stop
RUN chmod 755 entrypoint.sh


ENTRYPOINT ["./entrypoint.sh"]
