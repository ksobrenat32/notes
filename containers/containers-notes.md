# Container notes

> You can change podman to docker and viceversa, it should just work

## Deleting all containers including its volumes

    podman rm -vf $(podman ps -a -q)

## Deleting all the images

    podman rmi -f $(podman images -a -q)

## Building images

    podman build -t name:version .

## Watching logs

    podman logs --tail 50 --follow --timestamps name-of-the-container

## Creating systemd services with podman

[Documentation](http://docs.podman.io/en/latest/markdown/podman-generate-systemd.1.html)

> For running this as a user you need 'sudo loginctl enable-linger username'

### Generating the files

    podman generate systemd --files --name --restart-policy=always <name_of_pod_or_container>

Move all generated files to ~/.config/systemd/user/ or if you are root to/etc/systemd/system/

### Enable the service

    systemctl --user enable --now <name_of_pod.service>

### Check if it is enabled

    systemctl --user is-enabled <name_of_pod.service>

## Building image in podman with docker format

    podman build -t name:version --format docker .

## Using a system with selinux and podman

When mounting volumes use :z at the end.
   Example:

    podman run -it --rm -v ./thing/:/thing:z alpine sh

   or in a docker-compose.yml:

      - ./postgresdata:/var/lib/postgresql/data:z

## Extrating binaries from container

This is useful for example for a raspberry, when you
 want to run software without containers but there
 is no oficial binaries for aarch64 released only
 precompiled container, you can extract the binary
 from a oficial container image.

> Read the Containerfile first to know what are the dependencies

### Extracting binaries for vaultwarden

1. Pull the image for the architecture you want, be careful with tags.

     podman pull --platform linux/arm64 vaultwarden/server

2. Create but not start a container based on the image.

     podman create --name vw vaultwarden/server

3. Copy the needed binaries.

     podman cp vw:/vaultwarden .
     podman cp vw:/web-vault .

4. Delete container and image

     podman rm vw
     podman rmi vaultwarden/server:latest

