#/bin/bash

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
		cat $temp2 | sort -u > $finaloutput

		rm $temp1
		rm $temp2

		echo "END"
fi


