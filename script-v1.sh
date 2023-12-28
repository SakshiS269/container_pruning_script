#!/bin/bash

IMAGE_TAG="your_image_tag_here"  # Replace with the actual image tag
DAYS_THRESHOLD=3
OUTPUT_FILE="deleted_containers.txt"

# Get container IDs that match the specified image tag
CONTAINER_IDS=$(docker ps -a --filter "ancestor=${IMAGE_TAG}" --format "{{.ID}}")

# Loop through each container ID
for CONTAINER_ID in $CONTAINER_IDS; do
    # Get the creation timestamp of the container
    CREATED_AT=$(docker inspect --format="{{.Created}}" "${CONTAINER_ID}")

    # Calculate the age of the container in seconds
    AGE_SECONDS=$(( $(date +%s) - $(date -d "${CREATED_AT}" +%s) ))

    # Calculate the age of the container in days
    AGE_DAYS=$(( AGE_SECONDS / 86400 ))

    # Check if the container is older than the threshold
    if [ $AGE_DAYS -ge $DAYS_THRESHOLD ]; then
        echo "Deleting container ${CONTAINER_ID} created ${AGE_DAYS} days ago." >> "$OUTPUT_FILE"
        docker rm "${CONTAINER_ID}"
    fi
done
