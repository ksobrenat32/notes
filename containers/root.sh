#! /bin/bash

## Add the registries for container registries for images
function use-root () {
    	if ! [[ "$(id -u)" = 0 ]]; then
    	echo "Error, this script needs to be run as root"
    	exit 127
	fi
}

