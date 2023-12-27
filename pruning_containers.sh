#!/bin/bash

# Description: This Script prunes old running containers after a specific time period.

getVariables()
{
    echo "threshold:$threshold"
    echo "timelimit:$timelimit"
    echo "path:$path"
}

setVariables()
{
    #Defines the max number of continers running at specific instance of time.
    threshold=2

    #Defines the max allowed age of the containers.
    timelimit=30

    #Defines the path of the list_of_pruned_containers.txt file to store the record of deleted continers.
    path="/home/ubuntu/"

}

#calling setVariables function to set the values.
setVariables
# getVariables

#Making New Entry
cd $path
echo -e "\n\n---------------------------------------------------------------------------" >> list_of_pruned_containers.txt
date >> list_of_pruned_containers.txt
echo -e "\n---------------------------------------------------------------------------" >> list_of_pruned_containers.txt

container_info=$(sudo docker ps -a --format '{{.ID}}|{{.Names}}|{{.CreatedAt}}|{{.Image}}')
while IFS='|' read -r container_id container created_at base_image;
do
    created_date=$(date -d "$(echo $created_at | sed 's/\(.*\) UTC/\1/')" +%s)
    current_date=$(date +%s)
    #for days use this logic
    # age_days=$(( (current_date - created_date) / 86400 ))
    age_minutes=$(( (current_date - created_date) / 60 ))
    short_base=$(echo "$base_image" | cut -d ':' -f 1)
    ans=$(echo $(sudo docker ps -a --format '{{.Image}}' | grep -c "$short_base"))
    if [ "$age_minutes" -gt "$timelimit" ] && [ "$ans" -gt "$threshold" ];
    then
        echo "Deleting container: $container (ID: $container_id, created $age_minutes minutes ago) using base image: $base_image"

        #unlock the below comment to actually delete the continers, its locker for testing purpose.
        #sudo docker rm "$container_id"
        echo "$container_id || $container || $age_minutes || $base_image" >> list_of_pruned_containers.txt
    fi

done <<< "$container_info"
