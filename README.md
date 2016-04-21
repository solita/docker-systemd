# solita/ubuntu-systemd

A Docker image based on `ubuntu` that runs `systemd` with a minimal set of services.

## Supported tags

* `latest`, `16.04`

## But why?

The short answer: use `solita/ubuntu-systemd` for running applications that need to be run in a full Ubuntu system and not on their own as PID 1.

The long answer: `solita/ubuntu-systemd` might be a better choice than the stock `ubuntu` image if one of the following is true:

- You want to test a provisioning or deployment script that configures and starts `systemd` services.

- You want to run multiple services in the same container.

- You want to solve the [the PID 1 zombie reaping problem](https://blog.phusion.nl/2015/01/20/docker-and-the-pid-1-zombie-reaping-problem/).

If you just want to run a single, short-lived, process in a container, you should probably use the stock `ubuntu` image instead.

## Running

You need to add a couple of flags to the `docker run` command to make `systemd` play nice with Docker:

    docker run --stop-signal=SIGRTMIN+3 --tmpfs /run --tmpfs /run/lock -v /sys/fs/cgroup:/sys/fs/cgroup:ro YOUR_IMAGE

## License

Copyright © 2016 [Solita](http://www.solita.fi). Licensed under [the MIT license](LICENSE).
