#!/usr/bin/sh

mkdir -p src/
mkdir -p libs/
mkdir -p libs/bin


echo "Downlaoding GEOS source..."
cd src/
curl -O "http://download.osgeo.org/geos/geos-3.3.5.tar.bz2"

echo "Unpacking GEOS source..."
tar jxf geos-3.3.5.tar.bz2 

echo "Copying build script to GEOS source directory..."
cp ../build_ios geos-3.3.5

echo "Building GEOS..."
cd geos-3.3.5
sh build_ios -p $PWD/build/device_build device
make clean
sh build_ios -p $PWD/build/simulator_build simulator
lipo -arch i386 $PWD/build/simulator_build/lib/libgeos.a -arch armv7 $PWD/build/device_build/lib/libgeos.a -create -output ../../libs/bin/libgeos.a
lipo -arch i386 $PWD/build/simulator_build/lib/libgeos_c.a -arch armv7 $PWD/build/device_build/lib/libgeos_c.a -create -output ../../libs/bin/libgeos_c.a
cp -R build/simulator_build/include ../../libs/
cd ..

echo "Downloading PROJ4 source..."
curl -O http://download.osgeo.org/proj/proj-4.8.0.tar.gz

echo "Unpacking PROJ4 source..."
tar zxf proj-4.8.0.tar.gz

echo "Copying build script to PROJ4 source directory..."
cp ../build_ios proj-4.8.0

echo "building PROJ4"
cd proj-4.8.0
sh build_ios -p $PWD/build/device_build device
make clean
sh build_ios -p $PWD/build/simulator_build simulator
lipo -arch i386 $PWD/build/simulator_build/lib/libproj.a -arch armv7 $PWD/build/device_build/lib/libproj.a -create -output ../../libs/bin/libproj.a
cp -R build/simulator_build/include/* ../../libs/include
cd ../..

echo "All Done!"
