# Container notes

> You can change podman to docker and viceversa, it should just work

## Deleting all containers including its volumes

```bash
podman rm -vf $(podman ps -a -q)
```

## Deleting all the images

```bash
podman rmi -f $(podman images -a -q)
```

## Building images

```bash
podman build -t name:version .
```

## Watching logs

```bash
podman logs --tail 50 --follow --timestamps name-of-the-container
```

## Creating systemd services with podman

[Documentation](http://docs.podman.io/en/latest/markdown/podman-generate-systemd.1.html)

> For running this as a user you need 'sudo loginctl enable-linger username'

1. Generating the files
2. Enable the service
3. Check if it is enabled

```bash
podman generate systemd --files --name --restart-policy=always <name_of_pod_or_container>
systemctl --user enable --now <name_of_pod.service>
mv <name_of_pod.service>  ~/.config/systemd/user/
# if root : mv <name_of_pod.service>  /etc/systemd/system/
systemctl --user is-enabled <name_of_pod.service>
```

## Building image in podman with docker format

```bash
podman build -t name:version --format docker .
```

## Using a system with selinux and podman

When mounting volumes use :z at the end.
Example:

```bash
podman run -it --rm -v ./thing/:/thing:z alpine sh
```

or in a docker-compose.yml:

```bash
- ./postgresdata:/var/lib/postgresql/data:z
```

## Extrating binaries from container

This is useful for example for a raspberry, when you
 want to run software without containers but there
 is no oficial binaries for aarch64 released only
 precompiled container, you can extract the binary
 from a oficial container image.

> Read the Containerfile first to know what are the dependencies

### Extracting binaries for vaultwarden

1. Pull the image for the architecture you want, be careful with tags
2. Create but not start a container based on the image
3. Copy the needed binaries
4. Delete container and image

```bash
podman pull --platform linux/arm64 vaultwarden/server
podman create --name vw vaultwarden/server
podman cp vw:/vaultwarden .
podman cp vw:/web-vault .
podman rm vw
podman rmi vaultwarden/server:latest
```

## Ping from rootless container

In case you want to be able to use ping inside rootless containers,
 you can run:

```sh
echo -e 'net.ipv4.ping_group_range=0 165535' | sudo tee /etc/sysctl.d/podman-ping.conf
```

## Enable docker registrie on podman

In some distributions podman package it is not included the docker
 registrie so if you want to use it, you must specify it in the
 configuration.

 ```sh
mkdir -p $HOME/.config/containers/
echo -e "[registries.search]\nregistries = ['docker.io']" | tee $HOME/.config/containers/registries.conf
 ```

## Enable podman socket

For a rootless user:

```sh
systemctl --user enable --now podman.socket
export DOCKER_HOST=///run/user/$UID/podman/podman.sock
```
