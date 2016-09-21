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

Once you have the `.env` file set, make sure you have all the wordlists you want to use (apart from the wordlist generated from cewl) to bruteforce in the `wordlists` folder. 

And, thats it! You are ready to go :-)

First build the docker environment using:

```
docker-compsoe build
```

The build will take some time since it is going to build 5 images. Once you build the images, you can type `docker images` to make sure you see something like below:

![Docker Images](/img/dockerimages.png)

Then, run the docker environment using:
```
docker-compose up (if you want to see the output) OR docker-compose up -d (if you want to run it in the background as a daemon)
```

You can then always do a `docker ps -a` to view the containers that are running or exited like below:

![Docker Containers](/img/dockerps.png)



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

## Some things to understand
The `/data/` directory listed in the .env file above corresponds to the `/myoutdir` directory on your host that will get created when you start the environment. To understand this better, refer to the `docker-compose.yml` file and notice how I map the volumes for each container:

```
volumes:
            - ./myoutdir:/data
            - ./myoutdir/output:/data/output
```

This part can be slightly confusing so please let me know if you have any questions. 
Just remember that on your host, the directory structure is /myoutdir whereas on the docker containers, the directory structure is /data. All the output generated from the tools will be stored in their respective docker containers' /data directory which in turn is mapped to your /myoutdir host directory. Hence, you will see all output in the /myoutdir directory on your host. 

The wordlist generated from `cewl` will be stored at `./myoutdir/cewl.txt` hence you see that the `cewltmp` environment variable is set to `/data/cewl.txt` because again, `myoutdir` on the host corresponds to `data` on the docker containers.

Similarly, the final merged wordlist after running cewl and combining all the wordlists provided by you in the `wordlists` folder will be stored at `./myoutdir/subnames.txt`

The individual output from the tools will be stored at `./myoutdir/output/gobusteroutput.txt`, `./myoutdir/output/enumalloutput.txt` and `./myoutdir/output/sublist3routput.txt`

And, finally, the bruteforced subdomain list after running all 3 tools will be stored at `./myoutdir/finaloutput.txt`

### Please make sure that you include all the wordlists you want to use in the `wordlists` folder before issuing `docker-compose build`. Also, please make sure you first delete the `myoutdir` directory every time you run `docker-compose up` or `docker-compose up -d` against a new target. 


