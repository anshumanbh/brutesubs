FROM ubuntu:latest
MAINTAINER Anshuman Bhartiya <anshuman.bhartiya@gmail.com>

# Doing the usual here
RUN apt-get -y update && \
    apt-get -y dist-upgrade

# Installing the dependencies including "cewl" which is used to generate custom wordlists based on the target domain
RUN apt-get install -y cewl
