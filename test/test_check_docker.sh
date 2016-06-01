#!/bin/bash
script_dir="$(cd "$(dirname "$BASH_SOURCE")" && pwd)"
. "$script_dir/assert.sh"
. "$script_dir/../systemd-container-host-config"

installed_docker_version='1.11.1'
uname_result='Linux'

# If the installed Docker version is the expected version, require_docker
# prints nothing and succeeds.
assert 'require_docker 1.11.1' ''
assert_raises 'require_docker 1.11.1' 0

# If the installed Docker version is newer than expected, require_docker prints
# nothing and succeeds.
assert 'require_docker 1.9.0' ''
assert_raises 'require_docker 1.9.0' 0

# If the installed Docker version is older than expected, require_docker prints
# a message about requiring a newer Docker and fails.
assert_raises 'require_docker 1.12.0 2>&1 | grep -i newer'
assert_raises 'require_docker 1.12.0' 1

# If run on Windows or OS X and DOCKER_MACHINE_NAME is NOT set, require_docker
# prints a message about setting up Docker Machine and fails.
uname_result='Darwin'
unset DOCKER_MACHINE_NAME
assert_raises 'require_docker 1.11.1 2>&1 | grep -i docker-machine'
assert_raises 'require_docker 1.11.1' 1

# If run on Windows or OS X and DOCKER_MACHINE_NAME is set, require_docker
# prints nothing and succeeds.
DOCKER_MACHINE_NAME='default'
assert 'require_docker 1.11.1' ''
assert_raises 'require_docker 1.11.1' 0

assert_end
