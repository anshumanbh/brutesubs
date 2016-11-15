#/bin/sh

echo "We have the wordlists provided by you in the wordlists folder so merging and sorting all the wordlists inside that folder to form one big wordlist (W) to bruteforce against"
echo "Saving the final merged wordlist at /data/subnames.txt"
sort -u /opt/subscan/wordlists/* > $temp1
tr '[:upper:]' '[:lower:]' < $temp1 > $temp2
ln -s /usr/bin/fromdos /usr/bin/dos2unix
dos2unix $temp2
cat $temp2 | sort -u > $finalLOC
rm $temp1
rm $temp2

echo "Running Gobuster with the merged wordlist (W) with the following flags: -m dns -u <target> -w <merged wordlist> -t 100"
touch /tmp/gobuster.txt
chmod +x /tmp/gobuster.txt
$HOME/work/bin/gobuster -m dns -u $TARGETS -w $finalLOC -t 100 -fw > /tmp/gobuster.txt

echo "Fine tuning the Gobuster output to get only the subdomains using some grep and sed magic"
cat /tmp/gobuster.txt | grep Found | sed 's/Found: //' > $gobusterfile
rm /tmp/gobuster.txt
echo "Saving the Gobuster output to combine with the rest later"