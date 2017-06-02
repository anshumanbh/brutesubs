#!/bin/bash

if [ $# -eq 0 ]; then
    echo "No arguments provided. PLease provide a domain followed by an output directory like so:"
    echo "./brutesubs tesla.com tesla_output"
    exit 1
fi

domain=$1
save_folder=$2

#mkdir $2
#cp -a . $2
#cd $2
rm .env $

echo "TARGETS=$domain
DIRNAME=$save_folder

finalLOC=/data/subnames.txt
gobusterthreads=100
sublist3rthreads=50
altdnsthreads=100

wordlists=sorted_knock_dnsrecon_fierce_recon-ng.txt,bitquark_20160227_subdomains_popular_1000000.txt

temp1=/data/output/temp1.txt
temp2=/data/output/temp2.txt
temp3=/data/output/temp3.txt

gobusterfile=/data/output/gobusteroutput.txt
enumallfile=/data/output/enumalloutput.txt
sublist3rfile=/data/output/sublist3routput.txt

google_api=<>
google_cse=<>
shodan_api=

altdnsserver=8.8.8.8

finaloutputbeforealtdns=/data/finaloutputbeforealtdns.txt

altdnsoutput=/data/altdnsoutput.txt
altdnsonlysubs=/data/altdnsonlysubs.txt

finaloutputafteraltdns=/data/finalresult.txt" > .env

docker-compose up
