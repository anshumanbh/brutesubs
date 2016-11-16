FROM ubuntu:latest
MAINTAINER Anshuman Bhartiya <anshuman.bhartiya@gmail.com>

# Doing the usual here
RUN apt-get -y update && \
    apt-get -y dist-upgrade

RUN apt-get install -y \
	curl \
	tofrodos \
	build-essential \
	git \
	libpcap-dev \
	libxml2-dev \
	libxslt1-dev \
	python-requests \
	python-dnspython \
	python-setuptools \
	python-dev \
	wget \
	zlib1g-dev && apt-get clean

RUN easy_install pip && pip install --upgrade pip

RUN mkdir /opt/subscan
WORKDIR /opt/subscan

# Install golang. 
RUN curl -O https://storage.googleapis.com/golang/go1.6.linux-amd64.tar.gz && \
	tar -xvf go1.6.linux-amd64.tar.gz && \
	mv go /usr/local && \
	export PATH=$PATH:/usr/local/go/bin && \
	mkdir $HOME/work && \
	export GOPATH=$HOME/work 

# Installing ALTDNS
RUN git clone https://github.com/infosec-au/altdns.git
WORKDIR /opt/subscan/altdns
RUN pip install -r requirements.txt

RUN mkdir /opt/secdevops
COPY scripts/* /opt/secdevops/
RUN chmod +x /opt/secdevops/*
