# brutesubs
An automation framework for running multiple open sourced subdomain bruteforcing tools (in parallel) using your own wordlists via Docker. If you are not familiar with Docker, I highly recommend you familiarize yourself first. 

I have blogged about the idea behind this framework here - https://abhartiya.wordpress.com/2016/09/20/brutesubs-an-automation-framework-for-running-multiple-subdomain-bruteforcing-tools-in-parallel-via-docker/. So, if you have a few mins and want to understand why this was needed, please feel free to read that blog. 


## So, how does the automation work? 
* I am using docker-compose to build separate images and start containers for those images. As of now, I have images for cewl, gobuster, enumall, sublist3r and altdns. I run these containers in a specific order hence the automation. I plan to include more tools and do more things than just bruteforce subdomains hence the framework. 

* To begin with, when you start the environment using `docker-compose`, the `cewl` container will start and run against the target. It will then generate a custom wordlist based on certain keywords used by the target. Please refer https://digi.ninja/projects/cewl.php for more information about cewl. 

* The remaining containers (`gobuster`, `enumall`, `sublist3r` and `altdns`) will also start simultaneously but wait till the wordlist from cewl is generated. This is because we want to combine this wordlist from cewl with the other wordlists that we will be providing in the `wordlists` folder to create a big merged wordlist in the end to bruteforce against.

* Once the wordlist from cewl is generated, it gets saved at `myoutdir/cewl.txt`. Then the `gobuster` container will kick in, it will combine that cewl wordlist with the other wordlists from the `wordlists` folder and save it at `myoutdir/subnames.txt` on the host. This merging of different wordlists takes care of all the sorting and removing duplicate words from the final merged wordlist. It will then start `gobuster` against the target with the merged wordlist (subnames.txt). The gobuster container runs gobuster with the following command: `$HOME/work/bin/gobuster -m dns -u $TARGETS -w $finalLOC -t 100 -fw`

* `enumall` and `sublist3r` containers will wait till the merged wordlist is created by the `gobuster` container. Once that merged wordlist exists, both `enumall` and `sublist3r` containers also kick in simultaneously starting off enumall and sublist3r against the target in their respective containers. The commands they are run with are:
`/usr/bin/python /opt/subscan/Sublist3r/sublist3r.py -d $TARGETS -t 50 -v -o $sublist3rfile` and 
`/usr/bin/python /opt/subscan/recon-ng/enumall.py -w $finalLOC $TARGETS`

* So, at this point, `cewl` container would have exited since it did its job. `gobuster`, `enumall` and `sublist3r` are running the tools against the target simultaneously and `altdns` container is waiting for all the tools to finish running.

* Once all the 3 tools (gobuster, enumall and altdns) finish running (which might take time depending upon how big the subnames.txt file is), their individual outputs are saved at `myoutdir/output`. If you don't wait for all of them to finish and need some attack surface to begin with, you can start looking at the individual output generated at that location. Sublist3r will most likely finish first since we are not using its bruteforcing module.

* After all the 3 tools finish running, the `altdns` container kicks in and runs altdns against the final output of the bruteforced subdomains. In the end, the altdns container will combine the results obtained from altdns, and the previously finished list of bruteforced subdomains and produce one final list of bruteforced subdomains that are valid and can be resolved. This is saved at `myoutdir` directory with the name `finalandaltdns.txt`. So, no false positives and hopefully no false negatives either after everything finishes.
 

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

Next, make sure you have the `.env` file setup in the same directory level where you have the `docker-compose.yml` file. I have provided a sample (sample-env) along with this repo. Make sure you rename it to `.env` after you add the required environment variables. 

Set the `TARGETS` variable to whatever domain you want to target. You can leave the `cewltmp`, `cewlLOC`, `LOC`, `finalLOC`, `temp1`, `temp2`, `temp3`, `temp4`, `gobusterfile`, `enumallfile`, `sublist3rfile`, `finaloutput`, `altdnsoutput`, `altdnsonlysubs` and `finalandaltdns` variables as is since the scripts leverage those values. Unless you know what you're doing, changing these values might break everything. Feel free to change the `resolveserver` and `altdnsserver` values if you need to. The only other variables apart from the `TARGETS` that you need to provide are `google_api`, `google_cse` and `shodan_api`. These keys are used in some modules implemented in Enumall. So, if you don't provide these, those modules wont run. Hence, no output from those modules. But, the overall automation would still work. 

Please consult https://bitbucket.org/LaNMaSteR53/recon-ng/wiki/Usage%20Guide to find out how to obtain `google_api` and `google_cse`. You will need both the keys to use the `recon/domains-hosts/google_site_api` domain in recon-ng.

Once you have the `.env` file set, make sure you have all the wordlists you want to use (apart from the wordlist generated from cewl because that will be generated once the cewl container is run) to bruteforce in the `wordlists` folder. I have provided some wordlists in the repo that I think should be pretty exhaustive but feel free to add/remove as necessary. 

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
You will notice that as soon as you start the environment, a new folder called "myoutdir" gets created in the same directory structure. This is the folder where all the outputs will get stored. Please note that everytime you want to run this environment against a new target, you would need to delete this folder completely. This is because some scripts check for the existence of some files in this directory and if they are present, even from the old target, they would take that into consideration. So, please remove the "myoutdir" directory after every run.

The `/data/` directory listed in the .env file above corresponds to this `/myoutdir` directory on your host that will get created when you start the environment. To understand this better, refer to the `docker-compose.yml` file and notice how I map the volumes for each container:

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

So on and so forth..I have also explained each environment variable in the `sample-env` file just in case there is confusion. 


## NOTE/GOTCHAS
* Please make sure that you include all the wordlists you want to use in the `wordlists` folder before issuing `docker-compose build`. 

* Please make sure you first delete the `myoutdir` directory every time you run `docker-compose up` or `docker-compose up -d` against a new target. 


## Some Screenshots from docker-compose logs

When Cewl just finished running, Gobuster created a merged wordlist (using cewl's wordlist and all the wordlists provided in the wordlists folder), enumall picked it up and kicked off. Simultaneously, Sublist3r kicked off as well:


![All3](/img/cewlsublist3renumall.png)



When Sublist3r finished running while Enumall is still running parallely:


![All2](/img/sublist3renumall.png)




When enumall finished, and GoBuster and Sublist3r had already finished earlier, endgame kicked off and combined all the output into one merged output:


![endgame](/img/enumallendgame.png)



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

* cewl is flaky sometimes. It just won't run hence everything else waiting on it won't run either. You can troubleshoot this by checking a few things:
	* Removing the docker images and rebuilding them again
	* Running cewl standalone and seeing if it actually runs by itself or not
	* change the cewl command in the docker-compose.yml file by decreasing the depth from 3 to 2 and see if that runs
	* I have had my AWS VPS IP blocked by Uber after running cewl a few times so thats a possibility as well. If that happens, cewl will not create any words and hence the entire automation will break

* The whole automation is slow right now just because of the number of words to bruteforce against. I will try to solve this by spawning more docker containers and splitting the wordlists. But, at this point, there is not much that can be done unfortunately. I have tried running it on AWS and it was surprisingly much much faster than running it locally. So, it is not that bad after all. 


