ARG VERSION="5.1"

# Assume this is run from capstone/debian directory
# Run in the root of the repo
# docker build -f ./debian/Dockerfile -t packager .
FROM debian:buster-slim

# Install necessary tools for packaging
RUN apt-get -qq update && \
    DEBIAN_FRONTEND=noninteractive apt-get -qq install -y \
        fakeroot dpkg-dev dos2unix

# Then install capstone from source
RUN mkdir /capstone

# Copy your project files into the container
COPY . /capstone

# Ensure make.sh is executable
RUN dos2unix /capstone/make.sh
RUN chmod +x /capstone/make.sh

# Run the make.sh script and install
WORKDIR /capstone/ 
RUN ./make.sh

# List files before make install
# RUN find / -type f > /before-install.txt

# Run make install
RUN make install

# List files after make install
# RUN find / -type f > /after-install.txt

# Create a package root directories
RUN mkdir -p /package-root/usr/include/capstone/
RUN mkdir -p /package-root/usr/lib/
RUN mkdir -p /package-root/usr/lib/pkgconfig/
RUN mkdir -p /package-root/usr/bin/

# Copy /usr/include/capstone/ to /package-root/usr/include/capstone/
RUN cp -r /usr/include/capstone/* /package-root/usr/include/capstone/
RUN cp -r /usr/lib/libcapstone* /package-root/usr/lib/
RUN cp -r /usr/lib/pkgconfig/capstone* /package-root/usr/lib/pkgconfig/
RUN cp -r /usr/bin/cstool /package-root/usr/bin/

# Create DEBIAN directory and control file
COPY ./debian/control /package-root/DEBIAN/control

# Update control file with the correct version
ARG VERSION
RUN sed -i "s/^Version:.*/Version: ${VERSION}/" /package-root/DEBIAN/control

# Build the package
RUN fakeroot dpkg-deb --build /package-root /capstone.deb

# The user can now extract the .deb file from the container with something like
# docker run --rm -v $(pwd):/out packager bash -c "cp /capstone.deb /out"