FROM ubuntu:latest
MAINTAINER Anshuman Bhartiya <anshuman.bhartiya@gmail.com>

# Doing the usual here
RUN apt-get -y update && \
    apt-get -y dist-upgrade

RUN apt-get install -y curl git tofrodos

RUN mkdir /opt/subscan && mkdir /opt/subscan/wordlists
WORKDIR /opt/subscan

# Install GOLANG and GOBUSTER. The directory after github.com (subscan in this case) can be named to anything
RUN curl -O https://storage.googleapis.com/golang/go1.6.linux-amd64.tar.gz && \
	tar -xvf go1.6.linux-amd64.tar.gz && \
	mv go /usr/local && \
	export PATH=$PATH:/usr/local/go/bin && \
	mkdir $HOME/work && \
	export GOPATH=$HOME/work && \
	mkdir -p $GOPATH/src/github.com/subscan/ && \
	cd $GOPATH/src/github.com/subscan/ && \
	git clone https://github.com/OJ/gobuster.git && \
	cd gobuster && \
	go get && go build && \
	go install

# Copying the wordlists in the end because every time you change a wordlist, the above commands are not being run again
RUN mkdir /opt/secdevops 
COPY scripts/* /opt/secdevops/
COPY wordlists/* /opt/subscan/wordlists/
RUN chmod +x /opt/secdevops/*