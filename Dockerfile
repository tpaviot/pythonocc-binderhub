# The Docker Hub jupyter/* images are frozen since October 2023,
# the maintained images live on quay.io
FROM quay.io/jupyter/scipy-notebook:latest
LABEL maintainer="Thomas Paviot <tpaviot@gmail.com>"

USER root

ENV DEBIAN_FRONTEND=noninteractive

##############
# apt update #
##############
RUN apt-get update && \
    apt-get install -y --no-install-recommends git wget libglu1-mesa-dev libgl1-mesa-dev libxmu-dev libxi-dev && \
    rm -rf /var/lib/apt/lists/*

###############################################################################
# Install pythonocc-core 8.0.1.1 and the notebook dependencies from conda-forge #
###############################################################################
# pythreejs: jupyter renderer
# gmsh: triangle_mesh_gmsh notebook
# ifcopenshell: ifc_display_basic_file notebook (built against occt 8.0.1)
RUN /opt/conda/bin/mamba install -y -c conda-forge \
        pythonocc-core=8.0.1.1 \
        pythreejs \
        gmsh \
        ifcopenshell && \
    /opt/conda/bin/mamba clean -afy

######################################
# Install pythonocc examples 8.0.1.1 #
######################################
WORKDIR /opt/build/
RUN git clone --branch 8.0.1.1 --depth 1 https://github.com/tpaviot/pythonocc-demos
WORKDIR /opt/build/pythonocc-demos
RUN cp -r /opt/build/pythonocc-demos/assets /home/jovyan/work && \
    cp -r /opt/build/pythonocc-demos/jupyter_notebooks /home/jovyan/work && \
    chown -R jovyan:users /home/jovyan/work

#####################
# back to user mode #
#####################
USER jovyan
WORKDIR /home/jovyan/work
