# Acaleph Ceph RadosGW

FROM ubuntu:trusty
MAINTAINER acaleph "admin@acale.ph"

RUN echo 'deb http://us.archive.ubuntu.com/ubuntu/ trusty universe' >> /etc/apt/sources.list
RUN echo 'deb http://us.archive.ubuntu.com/ubuntu/ trusty multiverse' >> /etc/apt/sources.list
RUN echo 'deb http://us.archive.ubuntu.com/ubuntu/ trusty-updates multiverse' >> /etc/apt/sources.list
RUN echo 'deb http://us.archive.ubuntu.com/ubuntu/ trusty-security multiverse' >> /etc/apt/sources.list

# make sure the package repository is up to date
RUN apt-get update

RUN apt-get install -y software-properties-common build-essential wget python python-pip

# Ceph repo
RUN wget -q -O- 'https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/release.asc' | apt-key add -
RUN echo deb http://ceph.com/debian-firefly/ $(lsb_release -sc) main | tee /etc/apt/sources.list.d/ceph.list
RUN apt-get update


# INSTALL SYSTEM DEPENDENCIES
RUN apt-get install ceph-common apache2 libapache2-mod-fastcgi radosgw -y
RUN apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

ENV PYTHONIOENCODING utf_8

RUN pip install honcho

ADD ./s3gw.fcgi /var/www/s3gw.fcgi
RUN chmod 555 /var/www/s3gw.fcgi

ADD ./httpd.conf /etc/apache2/httpd.conf
RUN a2enmod rewrite
RUN a2enmod fastcgi
ADD ./rgw.conf /etc/apache2/sites-available/rgw.conf
RUN a2ensite rgw.conf
RUN a2dissite default

RUN mkdir -p /var/log/ceph
RUN mkdir -p /var/lib/ceph/radosgw

ADD ./run.sh /opt/radosgw/run.sh
RUN chmod 777 /opt/radosgw/run.sh

ADD ./Procfile /opt/radosgw/Procfile

VOLUME ["/etc/ceph"]

EXPOSE 80
EXPOSE 443

WORKDIR /var/www
CMD ["start"]
ENTRYPOINT ["/opt/radosgw/run.sh"]
