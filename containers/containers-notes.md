> You can change podman to docker and viceversa, it should just work

### Deleting all containers including its volumes
	
	podman rm -vf $(podman ps -a -q)

### Deleting all the images
	
	podman rmi -f $(podman images -a -q)
	
### Building images
	
	podman build -t name:version .
	
### Watching logs
	
	podman logs --tail 50 --follow --timestamps name-of-the-container
	
### Creating systemd services with podman
[Documentation](http://docs.podman.io/en/latest/markdown/podman-generate-systemd.1.html)
> For running this as a user you need 'sudo loginctl enable-linger <username>'

Generating the files
	
	podman generate systemd --files --name --restart-policy=always <name_of_pod_or_container>

Move all generated files to ~/.config/systemd/user/ or if you are root to/etc/systemd/system/

Enable the service
	
	systemctl --user enable --now <name_of_pod.service>

Check if it is enable 
	
	systemctl --user is-enabled <name_of_pod.service>

### Building image in podman with docker format
	
	podman build -t name:version --format docker .

### Using a system with selinux and podman

When mounting volumes use :z at the end. Example:
		
	podman run -it --rm -v ./thing/:/thing:z alpine sh
	
or in a docker-compose.yml
	
	- ./postgresdata:/var/lib/postgresql/data:z
