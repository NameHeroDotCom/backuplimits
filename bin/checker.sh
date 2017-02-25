#!/bin/bash
#
#

awk '{print$2}' /etc/userdomains | grep -v nobody | sort | uniq | while read line
do
	INODES_LIMIT=0
	DISK_LIMIT=0
	FILES=$(/usr/bin/cl-quota -u $line  | tail -1 | awk '{print$2}')
	if [[ $FILES -gt 100000 ]]
	then
		INODES_LIMIT=1
	fi
	DISK=$(quota -v  $line | awk -F"[ |*]+" '/\/dev/ {print$3}')
        if [[ $DISK -gt 20000000 ]]
	then
		DISK_LIMIT=2
	elif [[ $DISK -gt 10000000 ]]
	then
		DISK_LIMIT=1
	fi

	if [[ $INODES_LIMIT -eq 1 || $DISK_LIMIT -eq 2 ]]
	then
		if [[ ! -f /etc/cpremote/status/$line ]]
		then
			echo $(date +"%D %T")" Automatic cpremote backup disabled for $line due to disk space ($DISK) exceeding 20GB or inodes ($FILES) exceeding 100000."
			touch /etc/cpremote/status/$line
		fi
	elif [[ -f /etc/cpremote/status/$line ]]
	then
		echo $(date +"%D %T")" Automatic cpremote backups re-enabled for $line due to disk space ($DISK) under 20GB and inodes ($FILES) under 100000."
		rm -f /etc/cpremote/status/$line
	fi

        if [[ $INODES_LIMIT -eq 1 || $DISK_LIMIT -ge 1 ]]
        then
		if [[ ! -z $(egrep "^FEATURELIST=default$" /var/cpanel/users/$line) ]]
		then
                	echo $(date +"%D %T")" cPanel backup functions disabled for $line due to disk space ($DISK) exceeding 10GB or inodes ($FILES) exceeding 100000."
                	sed -i 's,^FEATURELIST=default$,FEATURELIST=default.disable_backup,' /var/cpanel/users/$line
		fi
        elif [[ ! -z $(grep "FEATURELIST=default.disable_backup" /var/cpanel/users/$line) ]]
        then
                echo $(date +"%D %T")" cPanel backup functions  re-enabled for $line due to disk space ($DISK) under 10GB and inodes ($FILES) under 100000."
                sed -i 's,^FEATURELIST=default.disable_backup$,FEATURELIST=default,' /var/cpanel/users/$line
        fi
done
