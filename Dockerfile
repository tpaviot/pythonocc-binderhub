FROM jupyter/scipy-notebook:notebook-6.4.12
MAINTAINER Thomas Paviot <tpaviot@gmail.com>

USER root

ENV DEBIAN_FRONTEND=noninteractive

##############
# apt update #
##############
RUN apt-get update
RUN apt-get install -y wget libglu1-mesa-dev libgl1-mesa-dev libxmu-dev libxi-dev
RUN dpkg-reconfigure --frontend noninteractive tzdata

#########################################################
# Install pythonocc-core 7.7.0 from conda-forge channel #
#########################################################
RUN ls /opt
RUN /opt/conda/bin/conda config --set always_yes yes --set changeps1 no
RUN /opt/conda/bin/conda update -q conda
RUN /opt/conda/bin/conda info -a
RUN /opt/conda/bin/conda config --add channels https://conda.anaconda.org/conda-forge
RUN /opt/conda/bin/conda create --name=pyocc770 python=3.9
RUN source activate pyocc770
RUN /opt/conda/bin/conda install conda-verify libarchive anaconda-client conda-build
RUN /opt/conda/bin/conda install -c conda-forge pythonocc-core=7.7.0

#######################
# Run pythonocc tests #
#######################
RUN git clone https://github.com/tpaviot/pythonocc-core
WORKDIR /opt/build/pythonocc-core/test
RUN python run_tests.py
WORKDIR /opt/build

##############################
# Install pythonocc examples #
##############################
WORKDIR /opt/build/
RUN git clone https://github.com/tpaviot/pythonocc-demos
WORKDIR /opt/build/pythonocc-demos
RUN cp -r /opt/build/pythonocc-demos/assets /home/jovyan/work
RUN cp -r /opt/build/pythonocc-demos/jupyter_notebooks /home/jovyan/work

#############
# pythreejs #
#############
RUN /opt/conda/bin/pip install pythreejs

########
# gmsh #
########
#ENV CASROOT=/opt/build/occt762
#WORKDIR /opt/build
#RUN git clone https://gitlab.onelab.info/gmsh/gmsh
#WORKDIR /opt/build/gmsh
#RUN git checkout gmsh_4_10_5
#WORKDIR /opt/build/gmsh/build
#
#RUN cmake \
# -DCMAKE_BUILD_TYPE=RelWithDebInfo \
# -DENABLE_OCC=ON \
# -DENABLE_OCC_CAF=ON \
# -DCMAKE_INSTALL_PREFIX=/usr/local \
# ..
#
#RUN make && make install

################
# IfcOpenShell #
################
#WORKDIR /opt/build
#RUN git clone https://github.com/tpaviot/IfcOpenShell
#WORKDIR /opt/build/IfcOpenShell
#RUN git submodule update --init --remote --recursive
#RUN git checkout v0.7.0
#WORKDIR /opt/build/IfcOpenShell/build
#
#RUN cmake \
# -DCOLLADA_SUPPORT=OFF \
# -DBUILD_EXAMPLES=OFF \
# -DOCC_INCLUDE_DIR=/opt/build/occt762/include/opencascade \
# -DOCC_LIBRARY_DIR=/opt/build/occt762/lib \
# -DLIBXML2_INCLUDE_DIR:PATH=/usr/include/libxml2 \
# -DLIBXML2_LIBRARIES=xml2 \
# -DPYTHON_LIBRARY=/opt/conda/lib/libpython3.8.so \
# -DPYTHON_INCLUDE_DIR=/opt/conda/include/python3.8 \
# -DPYTHON_EXECUTABLE=/opt/conda/bin/python \
# ../cmake
#
#RUN make && make install

#####################
# back to user mode #
#####################
USER jovyan
WORKDIR /home/jovyan/work
