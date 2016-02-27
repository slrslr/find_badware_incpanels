# find_badware_incpanels

Linux Bash script to search new Cpanel accounts files for bad/malicious phrasses and report bad files to WHM admin

----

Into file "find_badware_incpanels_phrasses" add phrasses (one per line) that you want to search in cpanel accounts. bad phrasses within php, js, html files

Bad file is reported to admin only if it contains whole line. I think it do not care about lower/upper case. Rather do not add empty lines.
