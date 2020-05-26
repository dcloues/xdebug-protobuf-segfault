#!/bin/sh

set -euo pipefail

XDEBUG_VERSION=2.9.5
PROTO_VERSION=3.12.1
PHP_VERSION=7.4.6

usage() {
    cat <<EOF
Usage:
    -p php version (default: ${PHP_VERSION})
    -x xdebug version (default: ${XDEBUG_VERSION})
    -b protobuf version (default: ${PROTO_VERSION})
    -h show help and exit
EOF
    exit 0
}

while getopts 'hp:x:b:' c
do
    case $c in
        p) PHP_VERSION=$OPTARG ;;
        x) XDEBUG_VERSION=$OPTARG ;;
        b) PROTO_VERSION=$OPTARG ;;
        h) usage ;;
    esac
done

tag="xdebug-segfault-test:php-${PHP_VERSION}-xdebug-${XDEBUG_VERSION}-proto-${PROTO_VERSION}"
build_log="docker_build_php-${PHP_VERSION}-xdebug-${XDEBUG_VERSION}-proto-${PROTO_VERSION}.log"

echo "Building test image: ${tag}"
echo "Build logs are available in ${build_log}"

docker build \
    --build-arg XDEBUG_VERSION="${XDEBUG_VERSION}" \
    --build-arg PROTO_VERSION="${PROTO_VERSION}" \
    --build-arg PHP_VERSION="${PHP_VERSION}" \
    -t "${tag}" \
    . > $build_log

echo "Running segfault test"
docker run --rm ${tag} gdb -batch -ex "run" -ex "bt full" --args php -r 'var_dump(new \Google\Protobuf\Timestamp());'
