FROM ubuntu:22.04

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
build-essential \
flex \
bison \
gdb \
cmake \
git \
make \
&& rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
