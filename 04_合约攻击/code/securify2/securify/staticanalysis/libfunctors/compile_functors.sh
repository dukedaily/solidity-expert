g++ -fPIC -o functors.o -c functors.cpp
g++ -shared -o libfunctors.so functors.o
rm functors.o
