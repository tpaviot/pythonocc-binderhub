This projects provides a Dockerfile image that can be run from a binderhub jupyter notebook. You can run pythonocc online, just following this link:

insert image

insert both links

There are 3 branches

* the master branch contains this README file, including a link to the binderhub jupyter notebook

* the build-from-scratch branch contains a Dockerfile which downloads each required dependency source code (oce/smesh/pythonocc) and performs compilation of everything ;

* the precompiled-conda uses precompiled binary files for oce and smesh. Only pythonocc-core is compiled from scratch.
