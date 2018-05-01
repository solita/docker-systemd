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

CentOS's `systemd` expects `/run` to be a `tmpfs` file system, but it can't
mount the file system itself in an unprivileged container:

    --tmpfs /run

`systemd` needs read-only access to the kernel's cgroup hierarchies:

    -v /sys/fs/cgroup:/sys/fs/cgroup:ro

Allocating a pseudo-TTY is not strictly necessary, but it gives us pretty
color-coded logs that we can look at with `docker logs`:

    -t

## Testing

This image is useless as it's only meant to serve as a base for your own
images, but you can still create a container from it. First set up your Docker
host as described in Setup above. Then run the following command:

    docker run -d --name systemd --security-opt seccomp=unconfined --tmpfs /run -v /sys/fs/cgroup:/sys/fs/cgroup:ro -t solita/centos-systemd

Check the logs to see if `systemd` started correctly:

    docker logs systemd

If everything worked, the output should look like this:

    systemd 219 running in system mode. (+PAM +AUDIT +SELINUX +IMA -APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT +GNUTLS +ACL +XZ -LZ4 -SECCOMP +BLKID +ELFUTILS +KMOD +IDN)
    Detected virtualization docker.
    Detected architecture x86-64.

    Welcome to CentOS Linux 7 (Core)!

    Set hostname to <136c97f88746>.
    Initializing machine ID from random generator.
    Failed to install release agent, ignoring: File exists
    Running in a container, ignoring fstab device entry for /dev/disk/by-uuid/b5b1eafa-7605-4eea-83d6-9ee36e9b867a.
    [  OK  ] Reached target Swap.
    [  OK  ] Reached target Local File Systems.
    [  OK  ] Reached target Paths.
    [  OK  ] Created slice Root Slice.
    [  OK  ] Listening on Journal Socket.
    [  OK  ] Reached target Sockets.
    [  OK  ] Created slice System Slice.
    [  OK  ] Reached target Slices.
             Starting Create Volatile Files and Directories...
             Starting Journal Service...
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

Also check the journal logs:

    docker exec systemd journalctl

The output should look like this:

    -- Logs begin at Fri 2017-03-17 15:45:31 UTC, end at Fri 2017-03-17 15:45:31 UTC. --
    Mar 17 15:45:31 136c97f88746 systemd-journal[18]: Runtime journal is using 8.0M (max allowed 787.3M, trying to leave 1.1G free of 7.6G available → current limit 787.3M).
    Mar 17 15:45:31 136c97f88746 systemd-journal[18]: Runtime journal is using 8.0M (max allowed 787.3M, trying to leave 1.1G free of 7.6G available → current limit 787.3M).
    Mar 17 15:45:31 136c97f88746 systemd-journal[18]: Journal started
    Mar 17 15:45:31 136c97f88746 systemd[1]: Started Create Volatile Files and Directories.
    Mar 17 15:45:31 136c97f88746 systemd[1]: Reached target System Initialization.
    Mar 17 15:45:31 136c97f88746 systemd[1]: Starting System Initialization.
    Mar 17 15:45:31 136c97f88746 systemd[1]: Reached target Basic System.
    Mar 17 15:45:31 136c97f88746 systemd[1]: Starting Basic System.
    Mar 17 15:45:31 136c97f88746 systemd[1]: Starting Permit User Sessions...
    Mar 17 15:45:31 136c97f88746 systemd[1]: Started Daily Cleanup of Temporary Directories.
    Mar 17 15:45:31 136c97f88746 systemd[1]: Starting Daily Cleanup of Temporary Directories.
    Mar 17 15:45:31 136c97f88746 systemd[1]: Reached target Timers.
    Mar 17 15:45:31 136c97f88746 systemd[1]: Starting Timers.
    Mar 17 15:45:31 136c97f88746 systemd[1]: Starting Cleanup of Temporary Directories...
    Mar 17 15:45:31 136c97f88746 systemd[1]: Started Permit User Sessions.
    Mar 17 15:45:31 136c97f88746 systemd[1]: Reached target Multi-User System.
    Mar 17 15:45:31 136c97f88746 systemd[1]: Starting Multi-User System.
    Mar 17 15:45:31 136c97f88746 systemd[1]: Started Cleanup of Temporary Directories.
    Mar 17 15:45:31 136c97f88746 systemd[1]: Startup finished in 55ms.

To check for clean shutdown, in one terminal run:

    docker exec systemd journalctl -f

And in another shut down `systemd`:

    docker stop systemd

The journalctl logs should look like this on a clean(ish) shutdown:

    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Received SIGRTMIN+3.
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Stopped target Multi-User System.
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Stopping Multi-User System.
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Stopping Permit User Sessions...
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Stopped target Timers.
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Stopping Timers.
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Stopped Daily Cleanup of Temporary Directories.
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Stopping Daily Cleanup of Temporary Directories.
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Stopped Permit User Sessions.
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Stopped target Basic System.
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Stopping Basic System.
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Stopped target Sockets.
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Stopping Sockets.
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Stopped target Slices.
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Stopping Slices.
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Stopped target Paths.
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Stopping Paths.
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Stopped target System Initialization.
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Stopping System Initialization.
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Stopped Create Volatile Files and Directories.
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Stopping Create Volatile Files and Directories...
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Reached target Shutdown.
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Starting Shutdown.
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Stopped target Swap.
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Stopping Swap.
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Stopped target Local File Systems.
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Stopping Local File Systems.
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Unmounting /proc/fs...
    Mar 17 15:54:23 c8c99c8a80ea umount[29]: umount: /proc/irq: must be superuser to umount
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Unmounting /proc/irq...
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Unmounting /etc/hostname...
    Mar 17 15:54:23 c8c99c8a80ea umount[30]: umount: /etc/hostname: must be superuser to umount
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Unmounting /proc/kcore...
    Mar 17 15:54:23 c8c99c8a80ea umount[28]: umount: /proc/fs: must be superuser to umount
    Mar 17 15:54:23 c8c99c8a80ea umount[34]: umount: /proc/bus: must be superuser to umount
    Mar 17 15:54:23 c8c99c8a80ea umount[31]: umount: /proc/kcore: must be superuser to umount
    Mar 17 15:54:23 c8c99c8a80ea umount[32]: umount: /proc/sched_debug: must be superuser to umount
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Unmounting /proc/sched_debug...
    Mar 17 15:54:23 c8c99c8a80ea umount[35]: umount: /sys/firmware: must be superuser to umount
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Unmounting /etc/resolv.conf...
    Mar 17 15:54:23 c8c99c8a80ea umount[39]: umount: /proc/sysrq-trigger: must be superuser to umount
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Unmounting /proc/bus...
    Mar 17 15:54:23 c8c99c8a80ea umount[38]: umount: /dev/mqueue: must be superuser to umount
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Unmounting /sys/firmware...
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Unmounting /etc/hosts...
    Mar 17 15:54:23 c8c99c8a80ea umount[33]: umount: /etc/resolv.conf: must be superuser to umount
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Unmounting /proc/timer_stats...
    Mar 17 15:54:23 c8c99c8a80ea umount[40]: umount: /proc/asound: must be superuser to umount
    Mar 17 15:54:23 c8c99c8a80ea umount[36]: umount: /etc/hosts: must be superuser to umount
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Unmounting POSIX Message Queue File System...
    Mar 17 15:54:23 c8c99c8a80ea umount[37]: umount: /proc/timer_stats: must be superuser to umount
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Unmounting /proc/sysrq-trigger...
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Unmounting /proc/asound...
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Unmounting /proc/timer_list...
    Mar 17 15:54:23 c8c99c8a80ea umount[41]: umount: /proc/timer_list: must be superuser to umount
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: proc-irq.mount mount process exited, code=exited status=32
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Failed unmounting /proc/irq.
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: proc-fs.mount mount process exited, code=exited status=32
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Failed unmounting /proc/fs.
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: etc-hostname.mount mount process exited, code=exited status=32
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Failed unmounting /etc/hostname.
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: proc-kcore.mount mount process exited, code=exited status=32
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Failed unmounting /proc/kcore.
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: proc-sched_debug.mount mount process exited, code=exited status=32
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Failed unmounting /proc/sched_debug.
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: etc-resolv.conf.mount mount process exited, code=exited status=32
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Failed unmounting /etc/resolv.conf.
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: proc-bus.mount mount process exited, code=exited status=32
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Failed unmounting /proc/bus.
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: sys-firmware.mount mount process exited, code=exited status=32
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Failed unmounting /sys/firmware.
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: etc-hosts.mount mount process exited, code=exited status=32
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Failed unmounting /etc/hosts.
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: proc-timer_stats.mount mount process exited, code=exited status=32
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Failed unmounting /proc/timer_stats.
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: dev-mqueue.mount mount process exited, code=exited status=32
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Failed unmounting POSIX Message Queue File System.
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: proc-sysrq\x2dtrigger.mount mount process exited, code=exited status=32
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Failed unmounting /proc/sysrq-trigger.
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: proc-asound.mount mount process exited, code=exited status=32
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Failed unmounting /proc/asound.
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: proc-timer_list.mount mount process exited, code=exited status=32
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Failed unmounting /proc/timer_list.
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Reached target Unmount All Filesystems.
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Starting Unmount All Filesystems.
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Reached target Final Step.
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Starting Final Step.
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Starting Halt...
    Mar 17 15:54:23 c8c99c8a80ea systemd[1]: Shutting down.

## Contributors

* [Timo Mihaljov](https://github.com/noidi)
* [Andrew Wason](https://github.com/rectalogic)
* [Damian ONeill](https://github.com/damianoneill)
* [Jeroen Vermeulen](https://github.com/jeroenvermeulen)

## License

Copyright © 2016-2018 [Solita](http://www.solita.fi). Licensed under [the MIT license](https://github.com/solita/docker-systemd/blob/master/LICENSE).
