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
    ssh weavers@137.184.21.199 -i $1 'cd chartbuilder_demo/; mkdir build-new/';
​
}
​
receive_new_files () {
    echo -e "Copying new files to server";
    scp -i $1 -r ./build/* weavers@137.184.21.199:~/chartbuilder_demo/build-new/;
}
​
remove_previous_files_in_remote () {
    echo -e "Removing previous project files in Server";
    ssh weavers@137.184.21.199 -i $1 'cd chartbuilder_demo/; mv build/ build-old/; mv build-new/ build/; rm -rf build-old/;';
}
​
restart_pm2_process () {
    echo -e "Restarting PM2 Process";
    ssh weavers@137.184.21.199 -i $1 'cd chartbuilder_demo/; pm2 restart chartbuilder_demo;';
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
