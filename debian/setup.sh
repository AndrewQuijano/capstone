# !/bin/bash
set -eu

# Function to get the current Ubuntu version
get_os_version() {
    lsb_release -i -s 2>/dev/null
}

OS_VERSION=$(get_os_version)
if [[ "$OS_VERSION" != "Ubuntu" && "$OS_VERSION" != "Debian" ]]; then
    echo "ERROR: OS is not Ubuntu or Debian and unsupported"
    exit 1
fi

# Get the version number as an input
# Check if version argument is provided
if [[ $# -ne 1 ]]; then
    echo "ERROR: Version argument is required"
    exit 1
fi

# Get the version number as an input
version=$1

# Now build the packager container from that
pushd ../
docker build -f ./debian/Dockerfile -t packager --build-arg VERSION="${version}" .
popd

# Copy deb file out of container to host
docker run --rm -v $(pwd):/out packager bash -c "cp /capstone.deb /out"

# Check which files existed before and after 'make install' was executed.
# docker run --rm -v $(pwd):/out packager bash -c "cp /before-install.txt /out"
# docker run --rm -v $(pwd):/out packager bash -c "cp /after-install.txt /out"
# diff before-install.txt after-install.txt