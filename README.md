## backuplimits
Script to disable backup functions based on resource usage

**Limits**

- Resource usage above 100,000 inodes or 20GBs disables automatic cpremote backups. 
- Resource usage above 100,000 inodes or 20GBs disables the backup functionality from a users cPanel account. 

**Installation**

1. Clone the install to /opt/namehero/backuplimits
2. Create a cron job like the below. 

    ```0 1 * * * /opt/namehero/backuplimits/bin/checker.sh &>> /opt/namehero/backuplimits/logs/run_log```
    
3. Log file: /opt/namehero/backuplimits/logs/run_log
