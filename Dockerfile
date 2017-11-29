#bench Dockerfile

FROM ubuntu:16.04
MAINTAINER frappé

#install pre-requisites
USER root
RUN apt-get update
RUN apt-get install -y iputils-ping
RUN apt-get install -y git build-essential python-setuptools python-dev libffi-dev libssl-dev
RUN apt-get install -y redis-tools software-properties-common libxrender1 libxext6 xfonts-75dpi xfonts-base
RUN apt-get install -y libjpeg8-dev zlib1g-dev libfreetype6-dev liblcms2-dev libwebp-dev python-tk apt-transport-https libsasl2-dev libldap2-dev libtiff5-dev tcl8.6-dev tk8.6-dev
RUN apt-get install -y wget
RUN wget https://bootstrap.pypa.io/get-pip.py && python get-pip.py
RUN pip install --upgrade setuptools pip
RUN useradd -ms /bin/bash frappe
RUN apt-get install -y curl
RUN apt-get install -y rlwrap
RUN apt-get install redis-tools
RUN apt-get install -y nano

#install nodejs
USER root
RUN apt-get install curl
RUN curl https://deb.nodesource.com/node_6.x/pool/main/n/nodejs/nodejs_6.7.0-1nodesource1~xenial1_amd64.deb > node.deb \
 && dpkg -i node.deb \
 && rm node.deb
RUN apt-get install -y wkhtmltopdf

#clone bench repo
USER frappe
WORKDIR /home/frappe
RUN git clone -b develop https://github.com/frappe/bench.git bench-repo

#install bench
USER root
RUN pip install -e bench-repo
RUN apt-get install -y libmysqlclient-dev mariadb-client mariadb-common
RUN mkdir /home/frappe/frappe-bench
RUN chown -R frappe:frappe /home/frappe/*

#install sudo and add sudoers
USER root
RUN apt-get install sudo \
 && usermod -aG sudo frappe \
 && printf '# User rules for frappe\nfrappe ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/frappe

COPY ./conf/frappe/* /home/frappe/

USER frappe
WORKDIR /home/frappe/frappe-bench
