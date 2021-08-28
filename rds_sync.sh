#!/bin/bash
replica1=master-replica-1.czzuhjvwmmvx.us-east-1.rds.amazonaws.com
replica2=master-replica-2.czzuhjvwmmvx.us-east-1.rds.amazonaws.com
user=admin
password=admin123
option=$1
if [[ -z "$option" ]]; then
    echo "Invalid Input"
    exit 1
fi

if [ $option == 'start' ]
then

    mysql -u $user -p$password -h $replica1 -e "CALL mysql.rds_start_replication;"
    mysql -u $user -p$password -h $replica2 -e "CALL mysql.rds_start_replication;"

    rsync -av --exclude=wp-config.php /dev.efs_directory/ /var/www/html/

        elif [ $option == 'stop' ]
            then
                mysql -u $user -p$password -h $replica1 -e "CALL mysql.rds_stop_replication;"
                mysql -u $user -p$password -h $replica2 -e "CALL mysql.rds_stop_replication;"
else                                                                                                    
  echo "Wrong Input"
fi
