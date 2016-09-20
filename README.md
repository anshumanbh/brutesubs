# brutesubs
A framework for bruteforcing subdomains using multiple Open Sourced tools and choosing your own wordlists running in parallel via Docker



## Sample .env file

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
