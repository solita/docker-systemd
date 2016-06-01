#!/bin/bash
script_dir="$(cd "$(dirname "$BASH_SOURCE")" && pwd)"
. "$script_dir/assert.sh"
. "$script_dir/../systemd-container-host-config"

installed_docker_version='1.11.1'

# If the installed Docker version is the expected version, require_docker exits
# with 0.
assert_raises 'require_docker 1.11.1' 0

# If the installed Docker version is the expected version, require_docker
# doesn't print anything.
assert 'require_docker 1.11.1' ''

# If the installed Docker version is newer than expected, require_docker exits
# with 0.
assert_raises 'require_docker 1.9.0' 0

# If the installed Docker version is newer than expected, require_docker
# doesn't print anything.
assert 'require_docker 1.9.0' ""

# If the installed Docker version is older than expected, require_docker exits
# with 1.
assert_raises 'require_docker 1.12.0' 1

# If the installed Docker version is older than expected, require_docker prints
# a message about requiring a newer Docker.
assert_raises 'require_docker 1.12.0 2>&1 | grep -i newer'

assert_end
