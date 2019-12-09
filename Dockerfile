FROM jupyter/scipy-notebook:ad3574d3c5c7

MAINTAINER Thomas Paviot <tpaviot@gmail.com>

USER root

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update

RUN apt-get install -y wget git build-essential libgl1-mesa-dev libfreetype6-dev libglu1-mesa-dev libzmq3-dev libsqlite3-dev libicu-dev python3-dev libgl2ps-dev libfreeimage-dev libtbb-dev ninja-build bison autotools-dev automake libpcre3 libpcre3-dev tcl8.5 tcl8.5-dev tk8.5 tk8.5-dev libxmu-dev libxi-dev
RUN dpkg-reconfigure --frontend noninteractive tzdata

##############
# Swig 4.0.1 #
##############
WORKDIR /opt/build
RUN wget https://github.com/swig/swig/archive/rel-4.0.1.tar.gz -O swig-4.0.1.tar.gz
RUN tar -zxvf swig-4.0.1.tar.gz
WORKDIR /opt/build/swig-rel-4.0.1
RUN ./autogen.sh && ./configure && make -j3 && make install
RUN swig -version

################
# CMake 3.15.5 #
################
WORKDIR /opt/build
RUN wget https://github.com/Kitware/CMake/releases/download/v3.15.5/cmake-3.15.5.tar.gz
RUN tar -zxvf cmake-3.15.5.tar.gz
WORKDIR /opt/build/cmake-3.15.5
RUN ./bootstrap && make -j3 && make install

############################################################
# OCCT 7.4.0                                               #
# Download the official source package from OCE repository #
############################################################
WORKDIR /opt/build
RUN wget https://github.com/tpaviot/oce/releases/download/official-upstream-packages/opencascade-7.4.0.tgz
RUN tar -zxvf opencascade-7.4.0.tgz >> installed_occt740_files.txt
RUN mkdir opencascade-7.4.0/build
WORKDIR /opt/build/opencascade-7.4.0/build

RUN ls /usr/include
RUN cmake -G Ninja \
 -DINSTALL_DIR=/opt/build/occt740 \
 ..

RUN ninja install

RUN echo "/opt/build/occt740/lib" >> /etc/ld.so.conf.d/occt.conf
RUN ldconfig

RUN ls /opt/build/occt740
RUN ls /opt/build/occt740/lib

#############
# pythonocc #
#############
WORKDIR /opt/build
RUN git clone https://github.com/tpaviot/pythonocc-core
WORKDIR /opt/build/pythonocc-core
RUN git submodule update --init --remote --recursive
RUN git checkout 7.4.0beta2
WORKDIR /opt/build/pythonocc-core/build

RUN cmake -G Ninja \
 -DOCE_INCLUDE_PATH=/opt/build/occt740/include/opencascade \
 -DOCE_LIB_PATH=/opt/build/occt740/lib \
 -DSWIG_EXECUTABLE=/usr/local/bin/swig \
 -DPYTHONOCC_BUILD=Release \
 -DPYTHONOCC_WRAP_OCAF=ON \
 -DPYTHONOCC_WRAP_SMESH=OFF \
 ..
 
RUN ninja install

#######################
# Run pythonocc tests #
#######################
WORKDIR /opt/build/pythonocc-core/test
RUN python core_wrapper_features_unittest.py


##############################
# Install pythonocc examples #
##############################
WORKDIR /opt/build/
RUN git clone https://github.com/tpaviot/pythonocc-demos
WORKDIR /opt/build/pythonocc-demos
RUN git checkout 7.4.0beta2
RUN cp -r /opt/build/pythonocc-demos/assets /home/jovyan/work
RUN cp -r /opt/build/pythonocc-demos/jupyter_notebooks /home/jovyan/work


#############
# pythreejs #
#############
WORKDIR /opt/build
RUN git clone https://github.com/jovyan/pythreejs
WORKDIR /opt/build/pythreejs
RUN git checkout 2.1.1
RUN chown -R jovyan .
USER jovyan
RUN /opt/conda/bin/pip install --user -e .
WORKDIR /opt/build/pythreejs/js
RUN npm run autogen
RUN npm run build:all
USER root
RUN jupyter nbextension install --py --symlink --sys-prefix pythreejs
RUN jupyter nbextension enable pythreejs --py --sys-prefix

#####################
# back to user mode #
#####################
USER jovyan
WORKDIR /home/jovyan/work
