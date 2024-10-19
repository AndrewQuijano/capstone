ARG VERSION="5.1"

# Assume this is run from capstone/debian directory
# Run in the root of the repo
# docker build -f ./debian/Dockerfile -t packager .
FROM debian:buster-slim

# Install necessary tools for packaging
RUN apt-get -qq update && \
    DEBIAN_FRONTEND=noninteractive apt-get -qq install -y \
        fakeroot dpkg-dev dos2unix wget

# Install CMake 3.15 or higher
RUN wget https://github.com/Kitware/CMake/releases/download/v3.15.0/cmake-3.15.0-Linux-x86_64.sh && \
    chmod +x cmake-3.15.0-Linux-x86_64.sh && \
    ./cmake-3.15.0-Linux-x86_64.sh --skip-license --prefix=/usr/local && \
    rm cmake-3.15.0-Linux-x86_64.sh

# Then install capstone from source
RUN mkdir /capstone

# Copy your project files into the container
COPY . /capstone

# Run the make.sh script and install
WORKDIR /capstone/ 

# Using cmake, see BUILDING.md file
# For debug build change "Release" to "Debug"
RUN cmake -B build -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=1
RUN cmake --build build

# List files before cmake install
# RUN find / -type f > /before-install.txt

# Run make install, by default everything goes into /usr/local
RUN cmake --install build

# List files after cmake install
# RUN find / -type f > /after-install.txt

# Make directories as needed
RUN mkdir -p /package-root/usr/local/include/capstone/
RUN mkdir -p /package-root/usr/local/lib/pkgconfig/
RUN mkdir -p /package-root/usr/local/bin/

# Copy /usr/local/include/capstone/ to /package-root/usr/local/include/capstone/ and all other cases
RUN cp -r /usr/local/include/capstone/* /package-root/usr/local/include/capstone/
RUN cp -r /usr/local/lib/libcapstone* /package-root/usr/local/lib/
RUN cp -r /usr/local/lib/pkgconfig/capstone* /package-root/usr/local/lib/pkgconfig/
RUN cp -r /usr/local/bin/cstool /package-root/usr/local/bin/

# Create DEBIAN directory and control file
COPY ./debian/control /package-root/DEBIAN/control

# Update control file with the correct version
ARG VERSION
RUN sed -i "s/^Version:.*/Version: ${VERSION}/" /package-root/DEBIAN/control

# Build the package
RUN fakeroot dpkg-deb --build /package-root /capstone.deb

# The user can now extract the .deb file from the container with something like
# docker run --rm -v $(pwd):/out packager bash -c "cp /capstone.deb /out"