FROM jupyter/scipy-notebook:notebook-6.5.2
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
RUN /opt/conda/bin/conda install -c conda-forge pythreejs

########
# gmsh #
########
RUN /opt/conda/bin/conda install -c conda-forge gmsh

################
# IfcOpenShell #
################
#RUN /opt/conda/bin/conda install -c conda-forge ifcopenshell

#####################
# back to user mode #
#####################
USER jovyan
WORKDIR /home/jovyan/work
