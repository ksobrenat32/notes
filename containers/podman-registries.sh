#! /bin/bash

echo "This script adds the docker registrie to podman configuration"

echo -e "[registries.search]\nregistries = ['docker.io']" | sudo tee /etc/containers/registries.conf
