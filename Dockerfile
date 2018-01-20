FROM jupyter/scipy-notebook:27ba57364579

MAINTAINER Thomas Paviot <tpaviot@gmail.com>

USER root


RUN apt-get update
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:ubuntu-toolchain-r/test
RUN apt-get update
RUN apt-get install -y wget git build-essential libgl1-mesa-dev libfreetype6-dev libglu1-mesa-dev libzmq3-dev libsqlite3-dev libboost-all-dev libicu-dev python3-dev libgl2ps-dev libfreeimage-dev libtbb-dev g++-7 libopenblas-dev

######################
# use gcc-7 compiler #
######################
ENV CXX=g++-7
ENV CC=gcc-7

######################
# conda env creation #
######################
#RUN conda config --set always_yes yes --set changeps1 no
#RUN conda create -n pyocc_demo python=3.6
#RUN /bin/bash -c "source activate pyocc_demo"
RUN conda install -y -c conda-forge cmake=3.10.0 swig==3.0.12 ninja=1.8.2

#######
# OCE #
#######
WORKDIR /opt/build
RUN git clone https://github.com/tpaviot/oce
RUN mkdir oce/build && mkdir oce/install
WORKDIR /opt/build/oce/build
RUN git checkout OCE-0.18.2

RUN cmake -G Ninja \
 -DOCE_TESTING:BOOL=OFF \
 -DOCE_BUILD_SHARED_LIB:BOOL=ON \
 -DOCE_VISUALISATION:BOOL=ON \
 -DOCE_DATAEXCHANGE:BOOL=ON \
 -DOCE_OCAF:BOOL=ON \
 -DOCE_DRAW:BOOL=OFF \
 -DOCE_WITH_GL2PS:BOOL=ON \
 -DOCE_WITH_FREEIMAGE:BOOL=ON \
 -DOCE_MULTITHREAD_LIBRARY:STRING="TBB" \
 -DOCE_INSTALL_PREFIX=/opt/build/install/oce \
 ..

RUN ninja install

RUN echo "/opt/build/install/oce/lib" >> /etc/ld.so.conf.d/pythonocc.conf
RUN ldconfig

#########
# smesh #
#########
WORKDIR /opt/build
RUN git clone https://github.com/tpaviot/smesh
RUN mkdir smesh/build && mkdir smesh/install
WORKDIR /opt/build/smesh/build
RUN git checkout 6.7.5

RUN cmake -G Ninja \
 -DSMESH_TESTING:BOOL=OFF \
 -DOCE_INCLUDE_PATH=/opt/build/install/oce/include/oce \
 -DOCE_LIB_PATH=/opt/build/install/oce/lib \
 -DCMAKE_INSTALL_PREFIX=/opt/build/install/smesh \
 ..

RUN ninja install

RUN echo "/opt/build/install/smesh/lib" >> /etc/ld.so.conf.d/smesh.conf
RUN ldconfig

########
# gmsh #
########
ENV CASROOT=/opt/build/install/oce
WORKDIR /opt/build
RUN git clone https://gitlab.onelab.info/gmsh/gmsh
WORKDIR /opt/build/gmsh
RUN git checkout gmsh_3_0_6
WORKDIR /opt/build/gmsh/build

RUN cmake -G Ninja \
 -DENABLE_OCC=ON \
 -DENABLE_OCC_CAF=ON \
 -DCMAKE_INSTALL_PREFIX=/opt/build/install/gmsh \
 ..

RUN ninja install

#############
# pythonocc #
#############
WORKDIR /opt/build
RUN git clone https://github.com/tpaviot/pythonocc-core
WORKDIR /opt/build/pythonocc-core/build

RUN cmake -G Ninja \
 -DOCE_INCLUDE_PATH=/opt/build/install/oce/include/oce \
 -DOCE_LIB_PATH=/opt/build/install/oce/lib \
 -DPYTHONOCC_WRAP_OCAF=ON \
 -DPYTHONOCC_WRAP_SMESH=ON \
 -DSMESH_INCLUDE_PATH=/opt/build/install/smesh/include/smesh \
 -DSMESH_LIB_PATH=/opt/build/install/smesh/lib \
 ..
 
RUN ninja install

#######################
# Run pythonocc tests #
#######################
WORKDIR /opt/build/pythonocc-core/test
RUN python core_wrapper_features_unittest.py
#RUN python run_examples_as_tests.py

##############################
# Install pythonocc examples #
##############################
WORKDIR /opt/build/pythonocc-core/examples/jupyter_notebooks
RUN cp *.ipynb /home/jovyan/work

#############
# pythreejs #
#############

WORKDIR /opt/build
RUN git clone https://github.com/jovyan/pythreejs
WORKDIR /opt/build/pythreejs
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