# find_badware_incpanels

Linux Bash script to search new Cpanel accounts files for bad/malicious phrasses and report bad files to WHM admin

Use on your risk, but it works for me.

----

INSTALLATION

1)

Into file "find_badware_incpanels_phrasses" add phrasses (one per line) that you want to search in cpanel accounts. bad phrasses within php, js, html files

Bad file is reported to admin only if it contains whole bad phrasse. I think it do not care about lower/upper case. Rather do not add empty lines into that file.

2) in main .sh file make sure to set your email address to get notiffied of new badware

3) can be run via cronjob, for example daily
