#!/bin/bash
​
start_deploy () {
    if [[ -z $1 ]]
    then
        echo -e "No Identity File.\nExiting";
        exit 1;
    else 
        echo -e "Path to identity file:\t" $1;
    fi
}
​
install_dependencies () {
    echo -e "Installing dependencies";
    npm install;
}
​
build_project () {
    echo -e "Building Project in Local Machine";
    npm run build;
    echo -e "Project Build Successful";
}
​
prep_to_receive_new_files () {
    echo -e "Preparing Server to receive new build";
    ssh weavers@3.80.198.11 -i $1 'cd weather-app/; mkdir build-new/';
​
}
​
receive_new_files () {
    echo -e "Copying new files to server";
    scp -i $1 -r ./build/* weavers@3.80.198.11:~/weather-app/build-new/;
}
​
remove_previous_files_in_remote () {
    echo -e "Removing previous project files in Server";
    ssh weavers@137.184.21.199 -i $1 'cd weather-app/; mv build/ build-old/; mv build-new/ build/; rm -rf build-old/;';
}
​
restart_pm2_process () {
    echo -e "Restarting PM2 Process";
    ssh weavers@3.80.198.11 -i $1 'cd weather-app/; pm2 restart weather-app;';
    echo -e "Deployment Complete";
}
​
start_deploy $1;
install_dependencies
build_project;
prep_to_receive_new_files $1;
receive_new_files $1;
remove_previous_files_in_remote $1;
restart_pm2_process $1;
exit 0;
