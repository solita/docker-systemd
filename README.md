# solita/centos-systemd

A Docker image based on `centos` that runs `systemd` with a minimal set of
services.

**This image is meant for development use only. We strongly recommend against
running it in production!**

## Supported tags

* `latest`, `7`

## But why?

The short answer: use `solita/centos-systemd` for running applications that
need to be run in a full CentOS system and not on their own as PID 1.

The long answer: `solita/centos-systemd` might be a better choice than the
stock `centos` image if one of the following is true:

- You want to test a provisioning or deployment script that configures and
  starts `systemd` services.

- You want to run multiple services in the same container.

- You want to solve the [the PID 1 zombie reaping problem](https://blog.phusion.nl/2015/01/20/docker-and-the-pid-1-zombie-reaping-problem/).

If you just want to run a single, short-lived process in a container, you
should probably use the stock `centos` image instead.

## Setup

Before you start your first `systemd` container, run the following command to
set up your Docker host. It uses [special privileges](https://docs.docker.com/engine/reference/run/#/runtime-privilege-and-linux-capabilities)
to create a cgroup hierarchy for `systemd`. We do this in a separate setup
step so we can run `systemd` in unprivileged containers.

    docker run --rm --privileged -v /:/host solita/centos-systemd setup

## Running

You need to add a couple of flags to the `docker run` command to make `systemd`
play nice with Docker.

We must disable seccomp because `systemd` uses system calls that are not
allowed by Docker's default seccomp profile:

    --security-opt seccomp=unconfined

To an init process `SIGTERM` means "restart". We have to send `SIGRTMIN+3` to
tell `systemd ` to shut down:

    --stop-signal=SIGRTMIN+3

CentOS's `systemd` expects `/run` and `/run/lock` to be `tmpfs` file systems,
but it can't mount them itself in an unprivileged container:

    --tmpfs /run
    --tmpfs /run/lock

`systemd` needs read-only access to the kernel's cgroup hierarchies:

    -v /sys/fs/cgroup:/sys/fs/cgroup:ro

Allocating a pseudo-TTY is not strictly necessary, but it gives us pretty
color-coded logs that we can look at with `docker logs`:

    -t

## Testing

This image is useless as it's only meant to serve as a base for your own
images, but you can still create a container from it. First set up your Docker
host as described in Setup above. Then run the following command:

    docker run -d --name systemd --security-opt seccomp=unconfined --stop-signal=SIGRTMIN+3 --tmpfs /run --tmpfs /run/lock -v /sys/fs/cgroup:/sys/fs/cgroup:ro -t solita/centos-systemd

Check the logs to see if `systemd` started correctly:

    docker logs systemd

If everything worked, the output should look like this:

    systemd 219 running in system mode. (+PAM +AUDIT +SELINUX +IMA -APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT +GNUTLS +ACL +XZ -LZ4 -SECCOMP +BLKID +ELFUTILS +KMOD +IDN)
    Detected virtualization docker.
    Detected architecture x86-64.

    Welcome to CentOS Linux 7 (Core)!

    Set hostname to <cee62a9be33b>.
    Initializing machine ID from random generator.
    Failed to install release agent, ignoring: File exists
    Running in a container, ignoring fstab device entry for /dev/disk/by-uuid/0e0b8d54-d8cd-4612-aabe-9158c10014f5.
    [  OK  ] Reached target Swap.
    [  OK  ] Reached target Paths.
    [  OK  ] Reached target Local File Systems.
    [  OK  ] Created slice Root Slice.
    [  OK  ] Listening on Journal Socket.
    [  OK  ] Reached target Sockets.
    [  OK  ] Created slice System Slice.
             Starting Journal Service...
             Starting Create Volatile Files and Directories...
    [  OK  ] Reached target Slices.
    [  OK  ] Started Journal Service.
    [  OK  ] Started Create Volatile Files and Directories.
    [  OK  ] Reached target System Initialization.
    [  OK  ] Reached target Basic System.
             Starting Permit User Sessions...
    [  OK  ] Reached target Timers.
             Starting Cleanup of Temporary Directories...
    [  OK  ] Started Permit User Sessions.
    [  OK  ] Reached target Multi-User System.
    [  OK  ] Started Cleanup of Temporary Directories.

Shut down `systemd`:

    docker stop systemd

Finally check the logs to see if systemd shut down cleanly:

    docker logs systemd

A clean shutdown looks like this:

    [  OK  ] Stopped target Timers.
    [  OK  ] Stopped target Multi-User System.
             Stopping Permit User Sessions...
    [  OK  ] Stopped Permit User Sessions.
    [  OK  ] Stopped target Basic System.
    [  OK  ] Stopped target Paths.
    [  OK  ] Stopped target Sockets.
    [  OK  ] Stopped target System Initialization.
    [  OK  ] Stopped Create Volatile Files and Directories.
             Stopping Create Volatile Files and Directories...
    [  OK  ] Reached target Shutdown.
    Sending SIGTERM to remaining processes...
    Sending SIGKILL to remaining processes...
    Halting system.
    Exiting container.

## License

Copyright © 2016 [Solita](http://www.solita.fi). Licensed under [the MIT license](https://github.com/solita/docker-systemd/blob/master/LICENSE).
