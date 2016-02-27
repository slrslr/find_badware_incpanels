# Works on cPanel/WHM server, searching thru 15 newest cpanel accounts for files with bad code in them & report bad files via email
# In same directry like this script, should be file "find_badware_incpanels_phrasses" which should contain all malicious phrasses that will be searched in new cpanels. All single and double quotation marks must be commented out by slash, example: /"something   . And be one bad phrasse per line.
# To make this script working regularly, automatically, setup this script as cronjob.


# variables (usually only "adminmail" and "thispath" needs to be editted)
adminmail=YOUR@gmail.com
thispath=/root/badwarefinder
reportcurrent=$thispath/reportcurrent
reportarchive=$thispath/reportarchive
badphrasses=$thispath/find_badware_incpanels_phrasses
> $reportcurrent

###################################

# add 15 log entries containing 15 newest cpanels into file
tail -n 50 /var/cpanel/accounting.log > /tmp/lastcpanels

# cpanel account loop
while read logline;do
# Add cpanel username and its domains into report for reference

# echo "logline: $logline"
# echo "logline useronly:"
cpusr=$(echo "$logline" | tail -c-9)
#echo $cpusr

existdir=$(bash -c '[ -d /usr/local/apache/domlogs/$cpusr/ ] && echo "exist"') 2> /dev/null
#echo "existdir: $existdir"

# echo "$cpusr exist check done"

if [[ "$existdir" == "exist" ]];then
echo "$cpusr, $(ls /usr/local/apache/domlogs/$cpusr 2> /dev/null | grep -v / 2> /dev/null)" >> $reportcurrent 2> /dev/null
fi

## echo "$(echo "$logline" | tail -c-9), $(echo $domlogdirexist)"

# search bad phrasses in cpanel account files
while read phrasse;do
/bin/nice -n 19 grep -sRil --include=*.{html,htm,js,php} "$phrasse" /home/$(echo "$logline" | tail -c-9)/public_html >> $reportcurrent
done < $badphrasses

done < /tmp/lastcpanels

# compare archive with current report and output only new file pathes
newfilesonly=$(/bin/nice -n 19 grep -v -x -f $reportarchive $reportcurrent | grep /)
# copy currently found file pathes into reportarchive
cat $reportcurrent | grep public_html >> $reportarchive

# report results via email
if [ "$(echo $newfilesonly | grep public_html | wc -l)" -gt "0" ];then
echo "Some suspicious files found at $(hostname):
$(cat $reportcurrent)

The file/s that was not yet reported are:
$newfilesonly" | mail -s "Suspicious files hosted on $(hostname)" $adminmail
fi
# this is the end
