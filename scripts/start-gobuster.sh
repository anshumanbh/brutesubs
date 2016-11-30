#!/bin/bash

echo "We have the wordlists you want to use specified in the environment file so merging and sorting them to form one big wordlist (W) to bruteforce against"
echo "Saving the final merged wordlist at /data/subnames.txt"

while IFS=',' read -ra ADDR; do
      for i in "${ADDR[@]}"; do
          c+=/opt/subscan/wordlists/$i" "
      done
done <<< $wordlists

sort -u $c > $temp1
tr '[:upper:]' '[:lower:]' < $temp1 > $temp2
ln -s /usr/bin/fromdos /usr/bin/dos2unix
dos2unix $temp2
cat $temp2 | sort -u > $finalLOC
rm $temp1
rm $temp2

echo "Running Gobuster with the merged wordlist (W) with the following flags: -m dns -u <target> -w <merged wordlist> -t $gobusterthreads"
touch /tmp/gobuster.txt
chmod +x /tmp/gobuster.txt
$HOME/work/bin/gobuster -m dns -u $TARGETS -w $finalLOC -t $gobusterthreads -fw > /tmp/gobuster.txt

echo "Fine tuning the Gobuster output to get only the subdomains using some grep and sed magic"
cat /tmp/gobuster.txt | grep Found | sed 's/Found: //' > $gobusterfile
rm /tmp/gobuster.txt
echo "Saving the Gobuster output to combine with the rest later"