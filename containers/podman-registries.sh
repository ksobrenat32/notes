#! /bin/bash

echo "This script adds the docker registrie to podman configuration"

mkdir $HOME/.config/containers
echo '[registries.search]' >> $HOME/.config/containers/registries.conf
echo 'registries = ['docker.io']' >> $HOME/.config/containers/registries.conf
