# solita/centos-systemd

A Docker image based on `centos` that runs `systemd` with a minimal set of services.

## Supported tags

* `latest`, `7`

## But why?

The short answer: use `solita/centos-systemd` for running applications that need to be run in a full CentOS system and not on their own as PID 1.

The long answer: `solita/centos-systemd` might be a better choice than the stock `centos` image if one of the following is true:

- You want to test a provisioning or deployment script that configures and starts `systemd` services.

- You want to run multiple services in the same container.

- You want to solve the [the PID 1 zombie reaping problem](https://blog.phusion.nl/2015/01/20/docker-and-the-pid-1-zombie-reaping-problem/).

If you just want to run a single, short-lived, process in a container, you should probably use the stock `centos` image instead.

## Configuring the Docker host

Unless your Docker host is running a recent Linux distribution, you'll need to configure the host by running the script [`systemd-container-host-config`](https://github.com/solita/docker-systemd/master/systemd-container-host-config). It will create the `systemd` cgroup, which must be present on the host when running `systemd` in a container. If you're worried about what the script might do, go ahead and [read it](https://github.com/solita/docker-systemd/master/systemd-container-host-config), it's short and not the most complicated thing in the world.

    curl https://github.com/solita/docker-systemd/master/systemd-container-host-config | sh

Note that the script will only make the changes persistent on `boot2docker` hosts. On other hosts the changes will be lost on reboot.

**[Docker for Mac and Docker for Windows](https://blog.docker.com/2016/03/docker-for-mac-windows-beta/) are currently unsupported.**

## Configuring the Docker host

Unless your Docker host is running a recent Linux distribution, you'll need to configure the host by running the script [`systemd-container-host-config`](https://github.com/solita/docker-systemd/master/systemd-container-host-config). It will create the `systemd` cgroup, which must be present on the host when running `systemd` in a container. If you're worried about what the script might do, go ahead and [read it](https://github.com/solita/docker-systemd/master/systemd-container-host-config), it's short and not the most complicated thing in the world.

    curl https://github.com/solita/docker-systemd/master/systemd-container-host-config | sh

Note that the script will only make the changes persistent on `boot2docker` hosts. On other hosts the changes will be lost on reboot.

**[Docker for Mac and Docker for Windows](https://blog.docker.com/2016/03/docker-for-mac-windows-beta/) are currently unsupported.**

## Running

You need to add a couple of flags to the `docker run` command to make `systemd` play nice with Docker:

    docker run \
      --security-opt seccomp=unconfined \
      --stop-signal=SIGRTMIN+3 \
      --tmpfs /run \
      -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
      YOUR_IMAGE

## License

Copyright © 2016 [Solita](http://www.solita.fi). Licensed under [the MIT license](https://github.com/solita/docker-systemd/blob/master/LICENSE).
