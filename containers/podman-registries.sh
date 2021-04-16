#! /bin/bash

## Add the registries for container registries for images (podman)

echo "This script adds the containers configuration"
use-root
echo '[registries.search]' >> /etc/containers/registries.conf
echo 'registries = ['container-registry.oracle.com', 'quay.io', 'docker.io']' >> /etc/containers/registries.conf
