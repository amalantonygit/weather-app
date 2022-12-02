#!/bin/bash

start_deploy () {
    if [[ -z $1 ]]
    then
        echo -e "No Identity File.\nExiting";
        exit 1;
    else 
        echo -e "Path to identity file:\t" $1;
    fi
}

prep_to_receive_new_files () {
    echo -e "Preparing Server to receive new build";
    ssh "ubuntu@$REMOTE_SERVER_IP" -i $1 -tt 'cd weather-app/; mkdir build-new/';
}

receive_new_files () {
    echo -e "Copying new files to server";
    scp -i $1 -r ./dist/* "ubuntu@$REMOTE_SERVER_IP":~/weather-app/build-new/;
}

remove_previous_files_in_remote () {
    echo -e "Removing previous project files in Server";
    ssh "ubuntu@$REMOTE_SERVER_IP" -i $1 -tt 'cd weather-app/; mv build/ build-old/; mv build-new/ build/; rm -rf build-old/;';
}

restart_pm2_process () {
    echo -e "Restarting PM2 Process";
    ssh "ubuntu@$REMOTE_SERVER_IP" -i $1 -tt 'cd weather-app/; pm2 delete weather-app || : && pm2 serve build 3000 --name weather-app';
    echo -e "Deployment Complete";
}

start_deploy $1;
prep_to_receive_new_files $1;
receive_new_files $1;
remove_previous_files_in_remote $1;
restart_pm2_process $1;
exit 0;
