# Container notes

Some useful commands and notes for container management with podman/docker.

## Managing containers

### Basic commands

**Listing containers:**

```sh
podman ps -a
```

**Deleting all containers:**

```sh
podman rm -a
```

**Deleting all container images:**

```sh
podman rmi -a
```

**Viewing logs with timestamps and follow:**

```sh
podman logs --tail 50 --follow --timestamps name-of-the-container
```

**Executing a command inside a running container:**

```sh
podman exec -it name-of-the-container bash
```

### Using quadlet

Quadlet is the new way of managing containers with systemd.

**Basic quadlet example:**

```sh
[Container]
Image=docker.io/library/postgres:16
AutoUpdate=registry
PublishPort=5432:5432
Volume=%h/volumes/test-db:/var/lib/postgresql/data:Z
Environment=POSTGRES_PASSWORD=CHANGE_ME

[Service]
Restart=always

[Install]
WantedBy=default.target
```

## Building images

**Building image in podman:**

```sh
podman build -t name:version .
```

**Building image in podman with docker format:**

```bash
podman build -t name:version --format docker .
```

## Tips and tricks

### Fast disposable container

In some cases I need to test some command in a distro, the fastest
 way of doing this is through a podman container, you can change
 fedora for the distro of your choice.

```sh
podman run -it --rm fedora bash
```

### Using a system with selinux and podman

When mounting volumes use :z if multiple containers need access
 to the volume or :Z if only that contasner needs access.

Example:

```sh
podman run -it --rm -v ./thing/:/thing:z alpine sh
```

or in a docker-compose.yml:

```sh
- ./postgresdata:/var/lib/postgresql/data:z
```

### Extrating binaries from container

This is useful for example for a raspberry, when you
 want to run software without containers but there
 is no oficial binaries for aarch64 released only
 precompiled container, you can extract the binary
 from a oficial container image.

> Read the Containerfile/Dockerfile first to know what are the dependencies

### Extracting binaries for Vaultwarden

1. Pull the image for the architecture you want, be careful with tags
2. Create but not start a container based on the image
3. Copy the needed binaries
4. Delete container and image

```sh
podman pull --platform linux/arm64 vaultwarden/server
podman create --name vw vaultwarden/server
podman cp vw:/vaultwarden .
podman cp vw:/web-vault .
podman rm vw
podman rmi vaultwarden/server:latest
```

### Ping from rootless container

In case you want to be able to use ping inside rootless containers,
 you can run:

```sh
echo -e 'net.ipv4.ping_group_range=0 165535' | sudo tee /etc/sysctl.d/podman-ping.conf
```

### Enable docker registry on podman

In some distributions podman package it is not included the docker
 registry so if you want to use it, you must specify it in the
 configuration.

```sh
mkdir -p $HOME/.config/containers/
echo -e "[registries.search]\nregistries = ['docker.io']" | tee $HOME/.config/containers/registries.conf
 ```

### Enable podman socket

This is useful for using podman with tools that
 expect a docker socket like portainer or docker-compose.

For a rootless user:

```sh
systemctl --user enable --now podman.socket
export DOCKER_HOST=///run/user/$UID/podman/podman.sock
```

### Problems with SELINUX

I had a problem when using the linuxserver's swag image
 where the image could not make the needed chown. To
 solve it, I added this to the podman command.

```sh
--security-opt label=disable
```
