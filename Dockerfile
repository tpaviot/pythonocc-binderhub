FROM ubuntu:22.04
MAINTAINER Thomas Paviot <tpaviot@gmail.com>

USER root

ENV DEBIAN_FRONTEND=noninteractive

##############
# apt update #
##############
RUN apt-get update
RUN apt-get install -y wget libglu1-mesa-dev libgl1-mesa-dev libxmu-dev libxi-dev
RUN apt-get install -y cmake

############################################################
# OCCT 7.7.2                                               #
# Download the official source package from git repository #
############################################################
WORKDIR /opt/build
RUN wget 'https://git.dev.opencascade.org/gitweb/?p=occt.git;a=snapshot;h=cec1ecd0c9f3b3d2572c47035d11949e8dfa85e2;sf=tgz' -O occt-7.7.2.tar.gz
RUN tar -zxvf occt-7.7.2.tar.gz >> extracted_occt772_files.txt
RUN mkdir occt-cec1ecd/build
WORKDIR /opt/build/occt-cec1ecd/build

RUN ls /usr/include
RUN cmake \
 -DINSTALL_DIR=/opt/build/occt772 \
 -DBUILD_RELEASE_DISABLE_EXCEPTIONS=OFF \
 ..

RUN make -j4 install

RUN echo "/opt/build/occt772/lib" >> /etc/ld.so.conf.d/occt.conf
RUN ldconfig

RUN ls /opt/build/occt772
RUN ls /opt/build/occt772/lib

#####################
# back to user mode #
#####################
USER jovyan
WORKDIR /home/jovyan/work
