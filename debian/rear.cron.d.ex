#
# Regular cron jobs for the rear package
#
0 4	* * *	root	[ -x /usr/bin/rear_maintenance ] && /usr/bin/rear_maintenance
