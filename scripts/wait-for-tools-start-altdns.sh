#!/bin/bash

while [[ ! -f $gobusterfile || ! -f $enumallfile || ! -f $sublist3rfile ]] ;
do
	echo "All tools haven't finished running yet so waiting.."
	sleep 30
done

if [ -f $gobusterfile ] && [ -f $enumallfile ] && [ -f $sublist3rfile ];
	then 
		echo "All tools have finished running."
		echo "Now, combining all output to produce the final bruteforced subdomains list"
		sort -u /data/output/* > $temp1
		tr '[:upper:]' '[:lower:]' < $temp1 > $temp2
		ln -s /usr/bin/fromdos /usr/bin/dos2unix
		dos2unix $temp2
		
		echo "Making sure only valid subdomains exist in the final output by running isresolveable.go file from the scripts directory"
		#for domains that cannot be resolved, it just prints a blank line
		/usr/local/go/bin/go run /opt/secdevops/isresolveable.go $temp2 > $temp3

		echo "Sorting the domains, removing blank lines, grepping to make sure it only contains domains related to the target"
		cat $temp3 | sort -u | grep $TARGETS > $finaloutputbeforealtdns

		rm $temp1 $temp2 $temp3

		echo "Now, running ALTDNS on the bruteforced subdomains obtained above"
		echo "The ALTDNS command used is altdns.py -i <finaloutput> -o data_output -w words.txt -r -e -d <altdnsserver> -s <altdnsoutputfile> -t $altdnsthreads"
		/usr/bin/python /opt/subscan/altdns/altdns.py -i $finaloutputbeforealtdns -o data_output -w words.txt -r -e -d $altdnsserver -s $altdnsoutput -t $altdnsthreads
		rm data_output

		#Assigning the target domain name to a TMP variable to be able to grep it later
		TMP=$(echo $TARGETS | cut -d'.' -f 1)

		echo "Getting the resolved subdomains from the ALTDNS output and combining them with the previously obtained bruteforced subdomains"
		cat $altdnsoutput | cut -d':' -f 1 > $altdnsonlysubs
		sort -u $finaloutputbeforealtdns $altdnsonlysubs | grep $TMP > $finaloutputafteraltdns

		# if running nmap, resolve all subdomains to their IP, sort IP, and run nmap against those unique IPs.
		# keep track of what subdomains are resolving to what IPs and what ports are open for a particular IP for posterity


		echo "END"
fi


