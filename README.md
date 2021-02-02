A Docker image for testing pythonocc at mybinder.org
----------------------------------------------------

### Available images

pythonocc-master: [![Binder](http://mybinder.org/badge.svg)](https://mybinder.org/v2/gh/tpaviot/pythonocc-binderhub/master)

pythonocc-7.4.1: [![Binder](http://mybinder.org/badge.svg)](https://mybinder.org/v2/gh/tpaviot/pythonocc-binderhub/7.4.1)

### About

This projects provides a Dockerfile image that can be run from a binderhub jupyter notebook. Just click the button below to launch the serer and test pythonocc within a jupyter notebook.

This docker file is based on the popular python 3.8 jupyter/scipy (see https://hub.docker.com/r/jupyter/scipy-notebook/) notebook that provides Jupyter Notebook 5.2.x, conda Python 3.8 environment, pandas, matplotlib, scipy, seaborn, scikit-learn, scikit-image, sympy, cython, patsy, statsmodel, cloudpickle, dill, numba, bokeh, vincent, beautifulsoup, xlrd pre-installed, unprivileged user jovyan (uid=1000, configurable, see options) in group users (gid=100) with ownership over /home/jovyan and /opt/conda.

The pythonocc-binderhub image provides the following additional packages:

* opencascade-7.4.0p2

* pythonocc-core 7.4.1

* pythreejs-2.2.1

* latest IfcOpenshell v0.6.0 dev branch

* gmsh-4.5.3
