if [ -x "$(command -v podman)" ]; then
    cli_cmd="podman"
elif [ -x "$(command -v docker)" ]; then
    cli_cmd="docker"
else
    echo "No container cli tool found! Aborting."
    exit -1
fi

${cli_cmd} run -v ${PWD}:/tmp/workdir:z --workdir /tmp/workdir ghcr.io/deb4sh/ci-terraform-image:sha-800a020 /bin/bash "./lint.sh"

