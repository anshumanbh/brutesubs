# brutesubs
An automation framework for running multiple open sourced subdomain bruteforcing tools (in parallel) using your own wordlists via Docker

I have blogged about the idea behind this framework here - https://abhartiya.wordpress.com/2016/09/20/brutesubs-an-automation-framework-for-running-multiple-subdomain-bruteforcing-tools-in-parallel-via-docker/

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

Next, make sure you have the `.env` file setup in the same directory level where you have the `docker-compose.yml` file. I have provided a sample below. Set the `TARGETS` variable to whatever domain you want to target. You can leave the `cewltmp`, `cewlLOC`, `LOC`, `finalLOC`, `temp1`, `temp2`, `gobusterfile`, `enumallfile`, `sublist3rfile` and `finaloutput` variables as is since the scripts leverage those values. Unless you know what you're doing, changing these values might break everything. The only other variables apart from the `TARGETS` that you need to provide are `google_api`, `google_cse` and `shodan_api`. These keys are used in some modules implemented in Enumall. So, if you don't provide these, those modules wont run. Hence, no output from those modules. But, the overall automation would still work. 

Once you have the `.env` file set, make sure you have all the wordlists you want to use (apart from the wordlist generated from cewl) to bruteforce in the `wordlists` folder. 

And, thats it! You are ready to go :-)

First build the docker environment using:

```
docker-compose build
```

The build will take some time since it is going to build 5 images. Once you build the images, you can type `docker images` to make sure you see something like below:

![Docker Images](/img/dockerimages.png)

Then, run the docker environment using:
```
docker-compose up (if you want to see the output) 
```
OR 
```
docker-compose up -d (if you want to run it in the background as a daemon)
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


## NOTE
Please make sure that you include all the wordlists you want to use in the `wordlists` folder before issuing `docker-compose build`. Also, please make sure you first delete the `myoutdir` directory every time you run `docker-compose up` or `docker-compose up -d` against a new target. 


## Some Screenshots from docker-compose logs

When Cewl just finished running, Gobuster created a merged wordlist (using cewl's wordlist and all the wordlists provided in the wordlists folder), enumall picked it up and kicked off. Simultaneously, Sublist3r kicked off as well:

![All3](/img/cewlsublist3renumall.png)

When Sublist3r finished running while Enumall is still running parallely:

![All2](/img/sublist3renumall.png)

When enumall finished, and GoBuster and Sublist3r had already finished earlier, endgame kicked off and combined all the output into one merged output:

![endgame](/img/enumallendgame.png)


## Future Ideas:

* Further fine tune the subdomains bruteforced
* Implement Alt-DNS on the subdomains generated
* Implement assetnote to notify of newly identified subdomains
* Implement port scanning, http screenshots, checking for hostile subdomains takeover type vulnerabilities
* Implement Directory bruteforcing
* Possibly extend the framework to include automation of more tools and such


## Troubleshooting:

If the dockerfiles fail to build sometimes, just run it again. It happens mostly because of network connections, atleast for me. 


