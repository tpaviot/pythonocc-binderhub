FROM ubuntu:22.04
MAINTAINER Thomas Paviot <tpaviot@gmail.com>

USER root

ENV DEBIAN_FRONTEND=noninteractive

##############
# apt update #
##############
RUN apt-get update
RUN apt-get install -y wget libglu1-mesa-dev libgl1-mesa-dev libxmu-dev libxi-dev
RUN apt-get install -y build-essential cmake libfreetype6-dev tk-dev python3-dev rapidjson-dev
RUN apt-get install -y python3 git python3-pip

RUN python3 -c "import sys; print(sys.path)"

##############
# SWIG 4.2.1 #
##############
# swig-4.2.1 is required, but not available on ubuntu ppa,
# we have to download/build/install
RUN apt-get install -y libpcre2-dev
WORKDIR /opt/
RUN wget http://prdownloads.sourceforge.net/swig/swig-4.2.1.tar.gz
RUN tar -zxvf swig-4.2.1.tar.gz
WORKDIR /opt/swig-4.2.1
RUN sh configure && make -j8 && make install

############################################################
# OCCT 7.8.1                                               #
# Download the official source package from git repository #
############################################################
WORKDIR /opt/build
RUN wget 'https://git.dev.opencascade.org/gitweb/?p=occt.git;a=snapshot;h=bd2a789f15235755ce4d1a3b07379a2e062fdc2e;sf=tgz' -O occt-7.8.1.tar.gz
RUN tar -zxvf occt-7.8.1.tar.gz >> extracted_occt781_files.txt
RUN mkdir occt-bd2a789/build
WORKDIR /opt/build/occt-bd2a789/build

RUN ls /usr/include
RUN cmake \
 -DINSTALL_DIR=/opt/occt781 \
 -DBUILD_RELEASE_DISABLE_EXCEPTIONS:BOOL=OFF \
 -DCMAKE_BUILD_TYPE:STRING="Release" \
 ..

RUN make -j8 && make install

RUN echo "/opt/occt781/lib" >> /etc/ld.so.conf.d/occt.conf
RUN ldconfig

RUN ls /opt/occt781
RUN ls /opt/occt781/lib

#############
# pythonocc #
#############
WORKDIR /opt/
RUN git clone https://github.com/tpaviot/pythonocc-core
WORKDIR /opt/pythonocc-core/build

RUN cmake \
 -DOCCT_INCLUDE_DIR=/opt/occt781/include/opencascade \
 -DOCCT_LIBRARY_DIR=/opt/occt781/lib \
 -DPYTHONOCC_INSTALL_DIRECTORY=/usr/lib/python3/dist-packages/OCC \
 -DCMAKE_BUILD_TYPE=Release \
 ..

RUN make -j4 && make install 

################################################
# six, required dependency, svg write optional #
################################################
RUN pip install svgwrite six

#######################
# Run pythonocc tests #
#######################
RUN pip install pytest
WORKDIR /opt/pythonocc-core/test
RUN pytest

#####################
# back to user mode #
#####################
USER jovyan
WORKDIR /home/jovyan/work
