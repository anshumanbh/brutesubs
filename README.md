# brutesubs

NOTE - This tool is not being developed or supporte anymore. You are free to take the code and do whatever you want to do with it but I am not going to work on this anymore. I have a better version of this which I use but is not open sourced. 

An automation framework for running multiple open sourced subdomain bruteforcing tools (in parallel) using your own wordlists via Docker. If you are not familiar with Docker, I highly recommend you familiarize yourself first. 

I have blogged about the idea behind this framework here - https://abhartiya.wordpress.com/2016/09/20/brutesubs-an-automation-framework-for-running-multiple-subdomain-bruteforcing-tools-in-parallel-via-docker/. So, if you have a few mins and want to understand why this was needed, please feel free to read that blog. 

UPDATE: I removed `cewl` from this orchestration because it wasn't adding anything new/useful.


## Pre-requisites
Understanding how Docker works is really important to be able to use this framework so I suggest spending some time and getting used to Docker before actually using this. I won't be able to help with any docker related questions unfortunately.



## So, how does the automation work? 
* I am using docker-compose to build separate images and start containers for those images. As of now, I have images for gobuster, enumall, sublist3r and altdns. I run these containers in a specific order hence the automation. I plan to include more tools and do more things than just bruteforce subdomains hence the framework. 

* To begin with, when you start the environment using `docker-compose`, the `gobuster` container will kick off. That will merge all the wordlists mentioned in the .env file. Make sure these wordlists are provided by you in the `wordlists` folder. The output of this merged wordlist is saved at `myoutdir/$DIRNAME/subnames.txt` on the host. It will then kick off Gobuster with that merged wordlist against the target mentioned in the `.env` file.

* The remaining containers (`enumall`, `sublist3r` and `altdns`) will also start simultaneously. However, out of these 3, the `enumall` and `sublist3r` containers will wait till the merged wordlist is generated above. This should be pretty quick. So, as soon as that merged wordlist is generated, Enumall and Sublist3r is kicked off as well with the merged wordlist against the target in their respective containers. `altdns` container will keep running and wait till all the above 3 tools finish running. 

* Once all the 3 tools (gobuster, enumall and altdns) finish running (which might take time depending upon how big the subnames.txt file is), their individual outputs are saved at `myoutdir/$DIRNAME/output`. If you don't wait for all of them to finish and need some attack surface to begin with, you can start looking at the individual output generated at that location. Sublist3r will most likely finish first since we are not using its bruteforcing module.

* After all the 3 tools finish running, the `altdns` container kicks in and runs altdns against the final output of the bruteforced subdomains. In the end, the altdns container will combine the results obtained from altdns, and the previously finished list of bruteforced subdomains and produce one final list of bruteforced subdomains that are valid and can be resolved. This is saved at `myoutdir/$DIRNAME` directory with the name `finalresult.txt`. So, no false positives and hopefully no false negatives either after everything finishes.

 

## Getting Started
You need docker and docker-compose. The easiest way I have found this to work is by installing `docker-machine`. That makes it really nice to work with different docker environments, whether locally or remote. The versions I have running are:
```
Docker version 1.12.1, build 23cf638
docker-compose version 1.8.0, build unknown
docker-machine version 0.8.1, build 41b3b25
```

So, once you have that, go ahead and git clone this repo.
```
git clone https://github.com/anshumanbh/brutesubs.git
```

Next, make sure you have the `.env` file setup in the same directory level where you have the `docker-compose.yml` file. I have provided a sample (sample-env) along with this repo. Make sure you rename it to `.env` after you add the required environment variables. Also, PLEASE REMOVE ALL THE COMMENTS FROM THE .ENV FILE. The tool will fail because it does not understand those comments. Those comments are there just to explain what each environment variable is for. 

Please consult https://bitbucket.org/LaNMaSteR53/recon-ng/wiki/Usage%20Guide to find out how to obtain `google_api` and `google_cse`. You will need both the keys to use the `recon/domains-hosts/google_site_api` domain in recon-ng.

Once you have the `.env` file set, make sure you have all the wordlists you want to use (mentioned in the .env file) to bruteforce in the `wordlists` folder. I have provided some wordlists in the repo that I think should be pretty exhaustive but feel free to add/remove as necessary. 

And, thats it! You are ready to go :-)

First build the docker environment using:

```
docker-compose build
```

The build will take some time since it is going to build a number of images. Once you build the images, you can type `docker images` to make sure you see something like below:

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



## Some things to understand
You will notice that as soon as you start the environment, a new folder called "myoutdir/$DIRNAME" gets created in the same directory structure. This is the folder where all the outputs will get stored. 

The `/data/` directory listed in the .env file above corresponds to this `/myoutdir/$DIRNAME` directory on your host that will get created when you start the environment. To understand this better, refer to the `docker-compose.yml` file and notice how I map the volumes for each container:

```
volumes:
            - ./myoutdir/$DIRNAME:/data
            - ./myoutdir/$DIRNAME/output:/data/output
```

This part can be slightly confusing so please let me know if you have any questions. `$DIRNAME` comes from the environment variable set in the .env file.
Just remember that on your host, the directory structure is /myoutdir/$DIRNAME whereas on the docker containers, the directory structure is /data. All the output generated from the tools will be stored in their respective docker containers' /data directory which in turn is mapped to your /myoutdir/$DIRNAME host directory. Hence, you will see all output in the /myoutdir/$DIRNAME directory on your host. 

The final merged wordlist after combining all the wordlists provided by you in the `wordlists` folder will be stored at `./myoutdir/$DIRNAME/subnames.txt`

The individual output from the tools will be stored at `./myoutdir/$DIRNAME/output/gobusteroutput.txt`, `./myoutdir/$DIRNAME/output/enumalloutput.txt` and `./myoutdir/$DIRNAME/output/sublist3routput.txt`

The final result from this orchestration will be stored at `./myoutdir/$DIRNAME/finalresult.txt`.

I have also explained each environment variable in the `sample-env` file just in case there is confusion. 



## NOTE/GOTCHAS
* Please make sure that you include all the wordlists you want to use in the `wordlists` folder and specify which ones you want to use in the `wordlists` environment variable, you set the `TARGETS` and `DIRNAME` environment variable correctly before issuing `docker-compose build`. 



## Future Ideas:

* Further fine tune the subdomains bruteforced - DONE
* Implement Alt-DNS on the subdomains generated - DONE
* Implement assetnote to notify of newly identified subdomains
* Implement port scanning, http screenshots, checking for hostile subdomains takeover type vulnerabilities
* Implement Directory bruteforcing
* Possibly extend the framework to include automation of more tools and such
* Split big wordlists to be able to improve the speed
* Notify new subdomains discovered by sending emails/SMS. Checking out assetnote for this



## Troubleshooting:

* If the dockerfiles fail to build sometimes, just run it again. It happens mostly because of network connections, atleast for me. 

* The whole automation is slow right now just because of the number of words to bruteforce against. I will try to solve this by spawning more docker containers and splitting the wordlists. But, at this point, there is not much that can be done unfortunately. I have tried running it on AWS and it was surprisingly much much faster than running it locally. So, it is not that bad after all. 


