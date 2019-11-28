A Docker image for testing pythonocc 7.4.0beta
----------------------------------------------

This projects provides a Dockerfile image that can be run from a binderhub jupyter notebook. Just click the button below to launch the serer and test pythonocc within a jupyter notebook.

[![Binder](http://mybinder.org/badge.svg)](https://mybinder.org/v2/gh/tpaviot/pythonocc-binderhub/master)

This docker file is based on the popular jupyter/scipy (see https://hub.docker.com/r/jupyter/scipy-notebook/) notebook that provides:

* Jupyter Notebook 5.2.x

* Conda Python 3.x environment

* pandas, matplotlib, scipy, seaborn, scikit-learn, scikit-image, sympy, cython, patsy, statsmodel, cloudpickle, dill, numba, bokeh, vincent, beautifulsoup, xlrd pre-installed

* Unprivileged user jovyan (uid=1000, configurable, see options) in group users (gid=100) with ownership over /home/jovyan and /opt/conda

* tini as the container entrypoint and start-notebook.sh as the default command

* A start-singleuser.sh script useful for running a single-user instance of the Notebook server, as required by JupyterHub

* A start.sh script useful for running alternative commands in the container (e.g. ipython, jupyter kernelgateway, jupyter lab)

* Options for HTTPS, password auth, and passwordless sudo

Moreover, the pythonocc-binderhub image provides additional packages:

* opencascade-7.4.0

* pythonocc-core 7.4.0beta

* pythreejs-2.1.1

* latest ifcopenshell dev master branch TODO

* gmsh-4.0.7 TODO

Check the [![Binderhub project](https://github.com/jupyterhub/binderhub)] to learn more about docker/git/jupyter.
