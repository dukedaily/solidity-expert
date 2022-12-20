It looks like that in version 1.6.2 of souffle the default shared library for
functors is functors.so and not libfunctors.so.
It is also important to remember to export the LD_LIBRARY_PATH or otherwise
souffle won't be able to link the shared library with the executable.   
