#!/bin/sh

while [ ! -f $finalLOC ] ;
do
	echo "The merged wordlist that was created from the GoBuster container does not exist yet so waiting.."
	sleep 10
done

if [ -f $finalLOC ];
	then echo "The merged wordlist exists now"
	while [ ! -s $cewltmp ];
		do
			echo "The merged wordlist exists but size is zero"
			sleep 10
		done
	echo "The merged wordlist exists and size is non-zero"
fi

echo "Running Sublist3r without bruteforcing enabled. Once Ahmed fixes the bruteforcing part, we can add that as well.."
echo "Sublist3r is run with the following flags: -d <TARGET> -t $sublist3rthreads -v -o"
/usr/bin/python /opt/subscan/Sublist3r/sublist3r.py -d $TARGETS -t $sublist3rthreads -v -o $sublist3rfile
echo "Sublist3r finished running. Saving the output to combine with the rest later"