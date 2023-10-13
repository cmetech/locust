#!/bin/bash

# Function to print usage
print_usage() {
    echo "Usage: $0 -t <image-tag> -v <version>"
    exit 1
}

# Parse command-line arguments
while getopts "t:v:" opt; do
    case $opt in
        t)
            IMAGE_TAG="$OPTARG"
            ;;
        v)
            VERSION="$OPTARG"
            ;;
        *)
            print_usage
            ;;
    esac
done

# Check for mandatory parameters
if [ -z "$IMAGE_TAG" ] || [ -z "$VERSION" ]; then
    print_usage
fi

# Check and switch to the desired branch
desired_branch="oscar-locust"
current_branch=$(git rev-parse --abbrev-ref HEAD)

if [ "$current_branch" != "$desired_branch" ]; then
    echo "Switching to branch $desired_branch..."
    git checkout "$desired_branch"

    # Optional: Pull the latest changes from the desired branch
    # git pull origin "$desired_branch"
fi

# Create a new Buildx instance
BUILDER_NAME="oscar_buildx"
docker buildx create --name "$BUILDER_NAME" --use

# Build and load the image into local Docker instance using Buildx
#docker buildx build --platform linux/amd64,linux/arm64 --tag "$IMAGE_TAG" .

docker buildx build --platform linux/amd64 --tag "${IMAGE_TAG}-amd64:${VERSION}" --load .
docker buildx build --platform linux/arm64 --tag "${IMAGE_TAG}-arm64:${VERSION}" --load .


# Remove the Buildx instance (optional)
docker buildx rm "$BUILDER_NAME"

echo "Image built and loaded successfully with tag: $IMAGE_TAG:${VERSION} for amd64 and arm64 platforms"
