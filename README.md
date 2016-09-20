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

Next, make sure you have the `.env` file setup. I have provided a sample below. Set the `TARGETS` variable to whatever domain you want to target. You can leave the `cewltmp`, `cewlLOC`, `LOC`, `finalLOC`, `temp1`, `temp2`, `gobusterfile`, `enumallfile`, `sublist3rfile` and `finaloutput` variables as is since the scripts leverage those values. Unless you know what you're doing, changing these values might break everything. The only other variables apart from the `TARGETS` that you need to provide are `google_api`, `google_cse` and `shodan_api`. These keys are used in some modules implemented in Enumall. So, if you don't provide these, those modules wont run. Hence, no output from those modules. But, the overall automation would still work. 

The `/data/` directory listed in the .env file below corresponds to the `/myoutdir` directory on your host that will get created when you start the environment. To understand this better, refer to the `docker-compose.yml` file and notice how I map the volumes for each container:
```
volumes:
            - ./myoutdir:/data
            - ./myoutdir/output:/data/output
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