FROM continuumio/miniconda3

WORKDIR /app

RUN conda create -n essai_env python=3.7

# Make RUN commands use the new environment:
SHELL ["conda", "run", "-n", "essai_env", "/bin/bash", "-c"]

# install the necessary stuff
RUN conda install -c conda-forge occt=7.5.0
# Make sure the environment is activated:
RUN python -c "from OCC.Core.BRepPrimAPI import BRepPrimAPI_MakeBox"
