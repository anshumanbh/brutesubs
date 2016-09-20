# brutesubs
A framework for bruteforcing subdomains using multiple Open Sourced tools and choosing your own wordlists running in parallel via Docker

## Getting Started

You need docker. The versions I have running are:
```
Docker version 1.12.1, build 23cf638
docker-compose version 1.8.0, build unknown
```

Once you have docker and docker-compose installed, go ahead and git clone this repo.
```
git clone https://github.com/anshumanbh/brutesubs.git
```


## Sample .env file

```
TARGETS=uber.com
cewltmp=/data/cewl.txt
cewlLOC=/opt/subscan/wordlists/cewlwordlist.txt
LOC=/opt/subscan/wordlists
finalLOC=/data/subnames.txt

temp1=/data/output/temp1.txt
temp2=/data/output/temp2.txt

gobusterfile=/data/output/gobusteroutput.txt
enumallfile=/data/output/enumalloutput.txt
sublist3rfile=/data/output/sublist3routput.txt

google_api=<>
google_cse=<>
shodan_api=<>

finaloutput=/data/finaloutput.txt
```