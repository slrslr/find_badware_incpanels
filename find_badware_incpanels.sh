# Works on cPanel/WHM server, searching thru 15 newest cpanel accounts for files with bad code in them & report bad files via email
# In same directry like this script, should be file "find_badware_incpanels_phrasses" which should contain all malicious phrasses that will be searched in new cpanels. All single and double quotation marks must be commented out by slash, example: /"something   . And be one bad phrasse per line.
# To make this script working regularly, automatically, setup this script as cronjob.


# variables (usually only "adminmail" and "thispath" needs to be editted)
adminmail=YOUR@gmail.com
thispath=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
reportcurrent=$thispath/reportcurrent
reportarchive=$thispath/reportarchive
badphrasses=$thispath/find_badware_incpanels_phrasses
> $reportcurrent

###################################

# If want to check last 25 cpanel accounts for bad files, then set tail command to list roughly last 50 lines
tail -n 90 /var/cpanel/accounting.log|grep CREATE > /tmp/lastcpanels

# discover suspended cpanels
suspended_cpanels=$(ls -A1 /var/cpanel/suspended)

# cpanel accounts loop
while read logline;do

cpusr=$(echo "$logline" | tail -c-9)
# skip to next user if this one is suspended
if [[ "$(echo "$suspended_cpanels")" == *"$cpusr"* ]];then
echo "$cpusr is in /var/cpanel/suspended, so lets skip to next user"
###### !!!!!!!!!!!!!!!!!!!!!!!!!!!!!! I temporarily disable skipping suspended panels, i need to discover if this script works to detect treats !!!!!!!!## continue
fi

existdir=$(bash -c '[ -d /usr/local/apache/domlogs/$cpusr/ ] && echo "exist"') 2> /dev/null

if [[ "$existdir" == "exist" ]];then
echo "$cpusr, $(ls /usr/local/apache/domlogs/$cpusr 2> /dev/null | grep -v / 2> /dev/null)" >> $reportcurrent 2> /dev/null
else
echo "$cpusr dir (/usr/local/apache/domlogs/$cpusr) does not exist. Existdir variable is $existdir . Skipping to next user."
continue
fi

## echo "$(echo "$logline" | tail -c-9), $(echo $domlogdirexist)"

echo "$cpusr files are examined"
while read phrasse;do
/bin/nice -n 19 find /home/$(echo "$logline" | tail -c-9)/public_html -size -1000k -mmin -1440 -name "*.htm*" -o -name "*.js" -o -name "*.php" ! -name "*continents-cities*" -exec grep -Fl "$phrasse" {} \; 2>/dev/null >> $reportcurrent
# size k kilobytes # mmin modiffied last n minutes 1440 = 24h
# /bin/nice -n 19 grep -Ril --include=*.{html,htm,js,php} "$phrasse" /home/$(echo "$logline" | tail -c-9)/public_html >> $reportcurrent
done < $badphrasses

done < /tmp/lastcpanels

# compare archive with current report and output only new file pathes
newfilesonly=$(/bin/nice -n 19 grep -v -x -f $reportarchive $reportcurrent | grep /)
# copy currently found file pathes into reportarchive
cat $reportcurrent | grep public_html >> $reportarchive

# report results via email
if [ "$(echo $newfilesonly | grep public_html | wc -l)" -gt "0" ];then
echo -e "Some suspicious files found at $(hostname) by $thispath:
$newfilesonly

Files reported in the past:
$(cat $reportcurrent)
" | mail -s "Suspicious files hosted on $(hostname)" $adminmail
fi

# this is the end
